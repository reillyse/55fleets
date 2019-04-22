class CreateCertificateLoadBalancers < ActiveRecord::Migration
  def change
    create_table :certificate_load_balancers do |t|
      t.integer :load_balancer_id
      t.integer :cert_id

      t.timestamps null: false
    end
  end
end
