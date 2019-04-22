class AddPermanentMinimumToPodConfigs < ActiveRecord::Migration
  def change
    add_column :pod_configs, :permanent_minimum, :integer
    add_column :pods, :permanent_minimum, :integer
  end
end
