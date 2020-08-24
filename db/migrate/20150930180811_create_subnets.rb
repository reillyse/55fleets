class CreateSubnets < ActiveRecord::Migration
  def change
    create_table :subnets do |t|
      t.integer :vpc_id
      t.string :subnet_id
      t.string :availability_zone
      t.timestamps null: false
    end
  end
end
