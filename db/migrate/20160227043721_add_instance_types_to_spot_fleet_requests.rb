class AddInstanceTypesToSpotFleetRequests < ActiveRecord::Migration
  def change
    add_column :spot_fleet_requests, :instance_types, :text
  end
end
