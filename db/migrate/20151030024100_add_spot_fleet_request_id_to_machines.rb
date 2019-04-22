class AddSpotFleetRequestIdToMachines < ActiveRecord::Migration
  def change
    add_column :machines, :spot_fleet_request_id, :integer
  end
end
