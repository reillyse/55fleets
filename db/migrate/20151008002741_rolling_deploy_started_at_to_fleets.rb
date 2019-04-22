class RollingDeployStartedAtToFleets < ActiveRecord::Migration
  def change
    add_column :fleets, :rolling_deploy_started_at, :datetime
    add_column :fleets, :rolling_deploy_completed_at, :datetime
    add_column :fleets, :rolling_deploy_failed_at, :datetime
  end
end
