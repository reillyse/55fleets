class ChangeSubnetIdToAnIntegerOnMachines < ActiveRecord::Migration
  def change
    remove_column :machines, :subnet_id
    add_column :machines, :subnet_id, :integer
  end
end
