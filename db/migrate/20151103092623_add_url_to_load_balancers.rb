class AddUrlToLoadBalancers < ActiveRecord::Migration
  def change
    add_column :load_balancers, :url, :string
  end
end
