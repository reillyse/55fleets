class ScaleBackBuildersWorker
  include Sidekiq::Worker

  def perform
    # all free and created 55 minutes ago suggests that we don't need them anymore
    if App.build_system.pods.first.machines.running.free.size > 0 &&
         App.build_system.pods.first.machines.running.free ==
           App.build_system.pods.first.machines.running &&
         App.build_system.pods.first.machines.running.all? do |m|
           m.created_at < 55.minutes.ago
         end
      Rails.logger.info 'Scaling back build system'
      App.kill_build_system
    end
  end
end
