class CreateVpcs < ActiveRecord::Migration
  def change
    create_table :vpcs do |t|
      t.text :name
      t.integer :app_id
      t.string :vpc_id
      t.string :state
      t.string :subnet_id
      t.string :availability_zone
      t.string :region      
      t.timestamps null: false
    end
  end
end
