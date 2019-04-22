class CreatePodConfigs < ActiveRecord::Migration
  def change
    create_table :pod_configs do |t|
      t.integer :fleet_config_id
      t.text :compose_command
      t.text :name
      t.integer :number_of_members
      t.text :repo_url
      t.text :instance_type
      t.text :instance_size
      t.timestamps null: false
    end
  end
end
