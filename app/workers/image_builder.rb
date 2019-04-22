class ImageBuilder < ActiveJob::Base
  include BaseWorker

  queue_as :high
  starting_state :created
  ending_state   :built
  class_name :pod

  def mutate pod

    begin
      Timeout::timeout(ENV["BUILD_TIMEOUT"] || 1200) do

        repo  = pod.repo

        Machine.transaction do
          pod.with_lock do

            @machine = App.build_system.pods.first.machines.running.free.lock.first
            if @machine.nil?
              # if we don't have a builder we wait, unless we don't have any build machines
              # and haven't started a spot fleet in 20 minutes
              Rails.logger.warn "No Builder machines available. Re-enqueue in 1 minute"
              BuildMachineStarter.perform_async
              raise "No Build Machines"
            end

            @app = repo.app
            pod.builder = @machine
            pod.save!
            @machine.busy = Time.now
            @machine.build_notes = "Building pod #{pod.id} for app #{pod.app.name} at #Time"
            @machine.save!

          end
        end #transaction over machine shouldn't be deadlocking now
        @machine.reload
        @machine.add_log("building",nil,pod)

        t = Terminal.new @machine
        puts "connecting...."

        t.upload StringIO.new(repo.private_deploy_key.to_s),"deploy_key"

        t.connect ["chmod 600 deploy_key","ssh-agent bash -c 'ssh-add deploy_key ; rm -rf deploy; git clone -b master #{repo.url} deploy'","rm -rf deploy_key" ]


        unless pod.git_ref.blank?
          t.connect ["cd deploy && git reset --hard #{pod.git_ref}"]
        end

        t1 = Thread.new do
          logger = Logger.new(STDOUT)
          logger.debug  "In new thread"

          t2 = Terminal.new @machine

          logger.debug "Building docker container"
          t2.connect ["echo 127.0.0.1 $(hostname)  | sudo tee -a  /etc/hosts"]
          @machine.add_log("Building pod",nil,pod)

          unless pod.before_hooks.blank?

            pod.before_hooks.each_line do |hook|
              puts hook
              next if hook.blank?
              hook = hook.strip
              if pod.compose_filename.blank?

                t2.connect [["cd deploy && #{pod.app.env_configs.map(&:for_bash).join} docker-compose run #{hook}","[ENV VARIABLES REDACTED...] docker-compose run #{hook}"]]

              else

                t2.connect [["cd deploy && #{pod.app.env_configs.map(&:for_bash).join} docker-compose -f #{pod.compose_filename} run #{hook}","[ENV VARIABLES REDACTED...] docker-compose run  -f #{pod.compose_filename} #{hook}"]]

              end
            end
          end
          if build_vars.blank?
            t2.connect [["cd deploy && #{pod.build_command}","HTTP_PROXY OFF:- #{pod.build_command}"]]
          else
            t2.connect [["cd deploy && #{build_vars} #{pod.build_command}","WITH HTTP_PROXY... #{pod.build_command}"]]
          end
          @machine.add_log("Running after hooks",nil,pod)
          unless pod.after_hooks.blank?

            pod.after_hooks.each_line do |hook|
              puts hook
              next if hook.blank?
              hook = hook.strip
              if pod.compose_filename.blank?

                t2.connect [["cd deploy && #{pod.app.env_configs.map(&:for_bash).join} docker-compose run #{hook}","[ENV VARIABLES REDACTED...] docker-compose run #{hook}"]]

              else

                t2.connect [["cd deploy && #{pod.app.env_configs.map(&:for_bash).join} docker-compose -f #{pod.compose_filename} run #{hook}","[ENV VARIABLES REDACTED...] docker-compose run  -f #{pod.compose_filename} #{hook}"]]

              end
            end
          end
        end
        $stdout.sync = true

        print "." until  t1.join(1)



        @machine.add_log("Pod Built #{pod.name}",nil,pod)
        pod.built_at = Time.now
        pod.build!

      end
    end
  rescue Timeout::Error => e
    Rails.logger.error e.message

    Rails.logger.error e.backtrace

    pod.persistant_errors.create! :message => e.message
    @machine.add_log(nil,e.message,pod) if @machine
    @machine.recycle_as_new if @machine
    raise e


  rescue => e
    Rails.logger.error e.message

    Rails.logger.error e.backtrace

    pod.persistant_errors.create! :message => e.message
    @machine.add_log(nil,e.message,pod) if @machine
    @machine.recycle_as_new if @machine
    raise e
  end


  def build_vars
    return ENV['BUILD_PROXY'].blank? ? "" : "HTTP_PROXY=#{ENV['BUILD_PROXY']} http_proxy=#{ENV['BUILD_PROXY']}"
  end
end
