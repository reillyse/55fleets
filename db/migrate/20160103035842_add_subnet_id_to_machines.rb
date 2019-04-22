class AddSubnetIdToMachines < ActiveRecord::Migration
  def change
    add_column :machines, :subnet_id, :string
  end
end
