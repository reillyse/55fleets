class Reaper < ActiveJob::Base 

  queue_as :low

  def perform instance_id
     
    begin
    @machine = Machine.find instance_id    
    puts "Reaper reaping #{instance_id}"
    puts "Reaper backtrace"
    @machine.shutdown! unless @machine.terminating?
    
    @machine.kill_instance

    rescue Aws::EC2::Errors::InvalidInstanceIDNotFound => e
      puts e.message
    ensure
      @machine.terminated!
    end
      
    
    
  end

end
