class AddFleetIdToPods < ActiveRecord::Migration
  def change
    add_column :pods, :fleet_id, :integer
  end
end
