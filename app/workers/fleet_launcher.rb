class FleetLauncher < ActiveJob::Base
  queue_as :high

  def perform(fleet_id, fleet_config_id)
    @fleet = Fleet.find fleet_id
    @fleet_config = FleetConfig.find fleet_config_id

    @fleet.launch(@fleet_config)
  end
end
