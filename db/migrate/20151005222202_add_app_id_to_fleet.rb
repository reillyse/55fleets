class AddAppIdToFleet < ActiveRecord::Migration
  def change
    add_column :fleets, :app_id, :integer
  end
end
