class AddLastHistoryCheckToSpotFleetRequests < ActiveRecord::Migration
  def change
    add_column :spot_fleet_requests, :last_history_check, :datetime
  end
end
