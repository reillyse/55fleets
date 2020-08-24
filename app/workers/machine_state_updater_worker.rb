class MachineStateUpdaterWorker
  include Sidekiq::Worker
  #  queue_as :high

  def perform(machine_id)
    @machine = Machine.find machine_id
    @machine.check_aws_status
    Rails.logger.debug "machine_id #{machine_id} checked"
  end
end
