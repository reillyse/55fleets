class InstanceMonitor
  include Sidekiq::Worker
  #do this every couple of 30 seconds


  def perform
    Rails.logger.debug "------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- run instance monitor"
    puts "-------******************************************************************************************************************************************************************************************************** running instance monitor"
    SpotFleetRequest.cleanup

    SpotFleetRequest.submitted.each { |s|
      begin
        SpotFleetRequest.transaction do
          Rails.logger.debug "acquiring lock on sfr #{s.id}"
          s.with_lock('FOR UPDATE NOWAIT') do
            next unless s.state == "submitted" || s.state.blank?
            s.update_my_fleet
            s.aws_history
          end
          Rails.logger.debug "releasing lock on sfr #{s.id}"
        end

      rescue Aws::EC2::Errors::InvalidSpotFleetRequestIdNotFound => e
        s.add_error("InstanceMonitor Error - #{e.message}")
        s.update_attribute :state, :error_terminated
        next
      rescue => e

        Rails.logger.error e.message
        Rails.logger.error "Processing next SpotFleetRequest"
        next
      end
    }


    SpotFleetRequest.active.each { |s|
      #why does this work?

      begin
        Rails.logger.debug "acquiring lock on sfr for instances  #{s.id}"
        new_machines = []
        s.with_lock('FOR UPDATE NOWAIT') do

          next unless s.state == "active"
          s.update_my_fleet
          Rails.logger.debug "updating instances for sfr == #{s.id}"
          s.update_instances s.pod.app == App.build_system
        end



        Rails.logger.debug "releasing lock on sfr for instances  #{s.id}"

      rescue Aws::EC2::Errors::InvalidSpotFleetRequestIdNotFound => e
        s.add_error("InstanceMonitor Error - #{e.message}")
        s.update_attribute :state, :error_terminated
        next


      rescue => e
        Rails.logger.error e.message
        Rails.logger.error "Processing next SpotFleetRequest"
        raise e
      end

    }


  end

end
