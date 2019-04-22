class BuildMachineStarter

  include Sidekiq::Worker

  def perform
    p = App.build_system.pods.first
    p.with_lock do
      Rails.logger.debug "-------------------- acquired lock at #{Time.now}"
      sfr = App.build_system.pods.map(&:spot_fleet_request).max(&:created_at)
      no_recent_machines_started   = sfr ? sfr.created_at < 20.minutes.ago : true
      if App.build_system.pods.first.machines.running.count == 0 &&  no_recent_machines_started
        App.recreate_build_system
      end
      Rails.logger.debug "-------------------- released lock at #{Time.now}"
    end
  end

end
