class AddLoadBalancedToPodConfigs < ActiveRecord::Migration
  def change
    add_column :pod_configs, :load_balanced, :boolean
  end
end
