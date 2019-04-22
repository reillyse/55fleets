class AddArnToLoadBalances < ActiveRecord::Migration
  def change
    add_column :load_balancers, :arn, :text
  end
end
