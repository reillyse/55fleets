class AddIndexToMachines < ActiveRecord::Migration[6.1]
  def change
    add_index :machines, :spot_fleet_request_id
    add_index :machines, :state
    add_index :machines, :subnet_id
    add_index :machines, :busy
    add_index :machines, %i[spot_fleet_request_id state]
    add_index :spot_fleet_requests, :pod_id
    add_index :spot_fleet_requests, :state
    add_index :pods, :builder_id
  end
end
