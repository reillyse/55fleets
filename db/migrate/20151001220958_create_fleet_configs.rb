class CreateFleetConfigs < ActiveRecord::Migration
  def change
    create_table :fleet_configs do |t|
      t.text :state
      t.integer :app_id
      t.integer :repo_id
      t.timestamps null: false
    end
  end
end
