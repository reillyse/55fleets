class FleetFlipper
  include Sidekiq::Worker

  def perform app_id

    @app = App.find app_id
    @app.latest_deployed_fleet.redeploy_this_fleet

  end

end
