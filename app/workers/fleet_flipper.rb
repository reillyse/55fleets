class FleetFlipper
  include Sidekiq::Worker

  def perform app_id

    @app = App.find app_id
    if Time.now.monday?
      Rails.logger.info("Re launching #{@app.name}")
      @app.latest_deployed_fleet.relaunch_this_fleet
    else
      @app.latest_deployed_fleet.redeploy_this_fleet
    end

  end

end
