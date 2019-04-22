class Birther < ActiveJob::Base

  queue_as = :high

  def perform machine_id
    @machine = Machine.find machine_id

    begin
      @machine.create_instance
    rescue => e
#      @machine.failed!
      raise e
    end

    @machine.starting!
    #wait for running
    @machine.running!

  end
end
