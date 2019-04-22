class AddLoadBalancedToPods < ActiveRecord::Migration
  def change
    add_column :pods, :load_balanced, :boolean
  end
end
