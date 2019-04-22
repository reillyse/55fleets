class CreateSpotFleetRequests < ActiveRecord::Migration
  def change
    create_table :spot_fleet_requests do |t|
      t.string :state
      t.string :client_token
      t.datetime :last_checked_at
      t.integer :vpc_id
      t.integer :app_id
      t.string :spot_fleet_request_id

      t.timestamps null: false
    end
  end
end
