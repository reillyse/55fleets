class AddInstanceCountToSpotFleetRequests < ActiveRecord::Migration
  def change
    add_column :spot_fleet_requests, :instance_count, :integer
  end
end
