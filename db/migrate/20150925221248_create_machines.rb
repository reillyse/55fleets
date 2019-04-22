class CreateMachines < ActiveRecord::Migration
  def change
    create_table :machines do |t|
      t.integer :app_id
      t.text :instance_id
      t.text :instance_type
      t.text :ip_address
      t.text :state
      t.datetime :started_at
      t.datetime :stopped_at      
      t.text :ami_name
      t.integer :vpc_id      
      t.timestamps null: false
    end
  end
end
