class AddIndexesForRequests < ActiveRecord::Migration
  def change
    add_index :fleets, :app_id
    add_index :machines, :ip_address
    add_index :machines, :instance_id
    add_index :machines, :pod_id
    add_index :pods, :fleet_id
  end
end
