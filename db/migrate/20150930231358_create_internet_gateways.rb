class CreateInternetGateways < ActiveRecord::Migration
  def change
    create_table :internet_gateways do |t|
      t.integer :vpc_id
      t.text :internet_gateway_id

      t.timestamps null: false
    end
  end
end
