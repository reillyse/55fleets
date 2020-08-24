class FleetFlipperScheduler
  include Sidekiq::Worker

  def perform
    App.active.should_flip.each do |app|
      FleetFlipper.perform_at(app.should_flip, app.id)
    end
  end
end
