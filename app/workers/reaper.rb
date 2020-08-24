class Reaper < ActiveJob::Base
  queue_as :low

  def perform(instance_id)
    @machine = Machine.find instance_id
    Rails.logger.debug "Reaper reaping #{instance_id}"
    Rails.logger.debug 'Reaper backtrace'
    @machine.shutdown! unless @machine.terminating?

    @machine.kill_instance
  rescue Aws::EC2::Errors::InvalidInstanceIDNotFound => e
    Rails.logger.debug e.message
  ensure
    @machine.terminated!
  end
end
