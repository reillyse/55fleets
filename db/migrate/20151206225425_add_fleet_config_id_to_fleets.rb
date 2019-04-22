class AddFleetConfigIdToFleets < ActiveRecord::Migration
  def change
    add_column :fleets, :fleet_config_id, :integer
  end
end
