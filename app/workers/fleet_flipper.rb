class FleetFlipper
  include Sidekiq::Worker

  def perform(app_id)
    @app = App.find app_id
    if Time.now.monday?
      Rails.logger.info("Re launching #{@app.name}")
      # @app.latest_deployed_fleet.relaunch_this_fleet

      fc = @app.fleets.last.fleet_config

      @fleet = Fleet.create! app: fc.app, fleet_config: fc
      FleetLauncher.perform_later(@fleet.id, fc.id)
    else
      @app.latest_deployed_fleet.redeploy_this_fleet
    end
  end
end
