class CreateLoadBalancers < ActiveRecord::Migration
  def change
    create_table :load_balancers do |t|
      t.text :name
      t.text :state
      t.text :subnet_id
      t.integer :app_id
      t.timestamps null: false
    end
  end
end
