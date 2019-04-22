class AddDeployedAtToMachines < ActiveRecord::Migration
  def change
    add_column :machines, :deployed_at, :datetime
  end
end
