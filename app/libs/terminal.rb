require 'net/ssh'
require 'net/scp'


class Terminal


  def initialize machine,user="ubuntu",key=nil,timeout=nil
    Rails.logger.debug "timeout = #{timeout}" if timeout
    @machine = machine
    @host = machine.ip_address
    @user = user
    @timeout = timeout || ENV["SSH_CONNECTION_TIMEOUT"] || 600
    if key.nil?

      @deploy_key = machine.app.deploy_key
      if @deploy_key
        @key = @deploy_key.private_key
      else
        SshKey.find_or_create_by_name_and_app("deploy_key_fleet",machine.app)
        @key = machine.app.reload.deploy_key.private_key

        #@key = Vault.find_by_name("gsg_key").data
      end

    end
  end

  def stream command
    Net::SSH.start(@host, @user,  :key_data => [ @key ], :timeout => @timeout) do |ssh|
      ssh.exec!(command) do |channel, stream, data|
        Rails.logger.debug data
      end
    end
  end

  def connect commands
    begin

      Net::SSH.start(@host, @user,  :key_data => [ @key ], :timeout => @timeout) do |ssh|

        commands.each do |command|
          if command.respond_to? :second
            log_line = command.second
            command = command.first
          end
          begin
            Rails.logger.debug "-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- jobs #{command}"
            out = ssh_exec!(ssh,command,"build",log_line)
            Rails.logger.debug "stdout == #{out[0]}"
            Rails.logger.debug "stderr == #{out[1]}"
            Rails.logger.debug "exit-code == #{out[2]}"
            Rails.logger.debug "exit-signal == #{out[3]}"
            Rails.logger.debug "machine id is #{@machine.id}"
            raise FailedCommandException,out[1] unless out[2] == 0
            raise FailedCommandException,out[1] if out[1].match("Service.*failed to build: The command.*returned a non-zero code:.*")
            Rails.logger.debug "finished executing #{command} "
          rescue Errno::ETIMEDOUT => e
            @machine.add_log(e.message)
            @machine.add_log("retrying...")
            Rails.logger.debug "  Timed out .. retrying"
            sleep(2)
            retry
          rescue Errno::EHOSTUNREACH
            Rails.logger.debug "  Host unreachable .. retrying"
            sleep(2)
            retry
          rescue Errno::ECONNREFUSED
            Rails.logger.debug "  Connection refused .. retrying"
            sleep(2)
            retry
          rescue Net::SSH::HostKeyMismatch => e
            Rails.logger.debug e.message
            e.remember_host!
            retry

          rescue Net::SSH::ConnectionTimeout => e
            @machine.add_log(e.message)
            @machine.add_log("retrying...")
            Rails.logger.debug e.message
            retry

          rescue Net::SSH::AuthenticationFailed
            Rails.logger.debug "  Authentication failure"
            raise
          end
        end
      end

    rescue Errno::ETIMEDOUT => e
      @machine.add_log(e.message)
      @machine.add_log("retrying...")
      Rails.logger.debug "  Timed out .. retrying"
      sleep(2)
      retry
    rescue Errno::EHOSTUNREACH
      Rails.logger.debug "  Host unreachable .. retrying"
      sleep(2)
      retry
    rescue Errno::ECONNREFUSED
      Rails.logger.debug "  Connection refused .. retrying"
      sleep(2)
      retry
    rescue Net::SSH::HostKeyMismatch => e
      Rails.logger.debug e.message
      e.remember_host!
      retry
    rescue Net::SSH::AuthenticationFailed
      Rails.logger.debug "  Authentication failure"
      raise

    rescue Net::SSH::ConnectionTimeout => e

      @machine.add_log(e.message)
      @machine.add_log("retrying...")
      Rails.logger.debug e.message
      retry
    end


  end

  def upload file, remote_file, dir = false
    begin
      result = Net::SCP.upload!(@host, @user,
                                file, remote_file,
                                :ssh => { :key_data => [@key] }, :recursive => dir) do |ch, name, sent, total|
        Rails.logger.debug "#{name}: (#{ ((sent.to_f / total.to_f) * 100).round(2)}%)"
      end
    rescue Errno::ETIMEDOUT
      Rails.logger.debug "  Timed out .. retrying"
      sleep(5)
      retry
    rescue Errno::EHOSTUNREACH
      Rails.logger.debug "  Host unreachable .. retrying"
      sleep(5)
      retry
    rescue Errno::ECONNREFUSED
      Rails.logger.debug "  Connection refused .. retrying"
      sleep(5)
      retry
    rescue Net::SSH::HostKeyMismatch => e
      Rails.logger.debug e.message
      e.remember_host!
      retry

    rescue Net::SSH::AuthenticationFailed
      Rails.logger.debug "  Authentication failure"
      raise

    end

    Rails.logger.debug result
  end

  def ssh_exec!(ssh, command,stage="build",log_line=nil)
    log_line = command if log_line.nil?
    stdout_data = ""
    stderr_data = ""
    exit_code = nil
    exit_signal = nil
    ssh.open_channel do |channel|
      channel.exec(command) do |ch, success|
        #wrap these log writes so they can fail
        LogEntry.write_log(:stdout =>  "executing:" + log_line, :machine_id => @machine.id, :pod_id => pod_or_nil(@machine), :stage => stage)
        unless success
          abort "FAILED: couldn't execute command (ssh.channel.exec)"
        end
        channel.on_data do |ch,data|
          stdout_data+= data
          Rails.logger.debug "stdout #{data}"
          LogEntry.write_log :stdout =>  data, :machine_id => @machine.id, :pod_id => pod_or_nil(@machine), :stage => stage
        end

        channel.on_extended_data do |ch,type,data|
          stderr_data+=data
          Rails.logger.debug "stderr: #{data}"
          LogEntry.write_log :stderr =>  data, :machine_id => @machine.id, :pod_id => pod_or_nil(@machine)
        end

        channel.on_request("exit-status") do |ch,data|
          exit_code = data.read_long
          LogEntry.write_log :exit_code =>  data.read_long, :machine_id => @machine.id, :pod_id => pod_or_nil(@machine)
        end

        channel.on_request("exit-signal") do |ch, data|
          exit_signal = data.read_long
          LogEntry.write_log :exit_signal =>  data.read_long, :machine_id => @machine.id, :pod_id => pod_or_nil(@machine)
        end
      end
    end
    ssh.loop
    [stdout_data, stderr_data, exit_code, exit_signal]
  end

  def pod_or_nil machine
    return machine.pod ? machine.pod.id : nil
  end
end
