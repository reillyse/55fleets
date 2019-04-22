class LogWorker
  include Sidekiq::Worker
  
  sidekiq_options :retry => false 


  def perform machine_id, log_for=5.minutes
    @machine = Machine.find(machine_id)
    raise "Can't attach to a dead machine" unless @machine.running?
    return nil if (@machine.logging_until || Time.now)  > Time.now
    begin
      Timeout.timeout(log_for + 1.minute) do
        LogHose.new(machine_id,log_for)
      end
    rescue => e
      puts e.message
      Rails.logger.warn e.inspect
      @machine.add_log(nil,"Log disconnected",@machine.pod)
      raise e
    end
  end 
end
