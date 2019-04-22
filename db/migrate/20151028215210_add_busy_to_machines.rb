class AddBusyToMachines < ActiveRecord::Migration
  def change
    add_column :machines, :busy, :string
  end
end
