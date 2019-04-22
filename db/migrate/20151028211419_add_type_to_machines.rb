class AddTypeToMachines < ActiveRecord::Migration
  def change
    add_column :machines, :type, :string
  end
end
