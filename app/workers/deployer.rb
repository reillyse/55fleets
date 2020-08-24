class Deployer < ActiveJob::Base
  queue_as :high

  def perform(machine_id)
    machine = Machine.find machine_id

    #key = Vault.find_by_name("gsg_key").data
    key = machine.app.deploy_key.name
    machine.add_log('Initializing Machine', nil, machine.pod)
    t = Terminal.new machine
    Rails.logger.debug 'connecting....'

    Timeout.timeout(20.minutes) do
      t1 =
        Thread.new do
          logger = Logger.new(STDOUT)
          logger.debug 'In new thread'
          t2 = Terminal.new machine
          t2.connect [
                       [
                         'echo 127.0.0.1 $(hostname)  | sudo tee -a  /etc/hosts',
                         'Configuring..'
                       ]
                     ]

          machine.app.ssh_keys.each do |key|
            t2.upload StringIO.new(key.to_s), 'ssh_key.pub'
            t2.connect [
                         'cat ssh_key.pub >> ~/.ssh/authorized_keys',
                         'rm -rf ssh_key.pub'
                       ]
          end

          logger.debug 'Starting docker compose'

          LogEntry.create! stdout:
                             "Running compose command = #{
                               machine.pod.compose_command
                             }",
                           machine_id: machine.id,
                           pod_id: machine.pod.id
          logger.debug "Running compose command = #{
                         machine.pod.compose_command
                       }"
          t2.connect [
                       [
                         "cd deploy && #{
                           machine.app.env_configs.map(&:for_bash).join
                         }  #{machine.pod.compose_command}",
                         "[ENV VARIABLES REDACTED...] #{
                           machine.pod.compose_command
                         }"
                       ]
                     ]

          LogEntry.create! stdout: 'Finished Starting',
                           machine_id: machine.id,
                           pod_id: machine.pod.id
          logger.debug 'Finished starting'
        end

      $stdout.sync = true

      print '.' until t1.join(1)
      machine.deployed_at = Time.now
      machine.deployed!
      machine.save!

      LogEntry.create! stdout: "Machine #{machine.ip_address} deployed",
                       machine_id: machine.id,
                       pod_id: machine.pod.id
      fleet = machine.fleet

      if fleet.rolling_deploy_started_at || machine.is_a?(SpotMachine)
        if machine.pod.load_balanced?
          fleet.app.load_balancers.where(state: 'running').each do |lb|
            lb.add_machine machine
          end
        end
      end

      fleet.roll_if_deployed
    end
  end
  def standard_envs
    return(
      "INSTANCE_TOTAL_MEM=`awk '/MemTotal/ {print $2}' /proc/meminfo` INSTANCE_TOTAL_CORES=`awk '/cpu cores/ {print $4}' /proc/cpuinfo |  head -1`"
    )
  end
end
