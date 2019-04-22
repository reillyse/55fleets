class LoadBalancerMachines < ActiveRecord::Migration
  def change
    create_table :load_balancers_machines do |t|
      t.integer :load_balancer_id
      t.integer :machine_id
    end
  end
end
