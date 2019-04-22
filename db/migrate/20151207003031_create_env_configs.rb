class CreateEnvConfigs < ActiveRecord::Migration
  def change
    create_table :env_configs do |t|
      t.text :encrypted_value
      t.text :encrypted_value_salt
      t.text :encrypted_value_iv
      t.integer :app_id
      t.integer :pod_id
      t.string :name
      t.timestamps null: false
    end
  end
end
