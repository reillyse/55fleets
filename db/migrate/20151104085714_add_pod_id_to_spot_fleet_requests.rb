class AddPodIdToSpotFleetRequests < ActiveRecord::Migration
  def change
    add_column :spot_fleet_requests, :pod_id, :integer
  end
end
