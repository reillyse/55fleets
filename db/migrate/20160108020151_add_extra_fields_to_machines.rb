class AddExtraFieldsToMachines < ActiveRecord::Migration
  def change

    add_column :machines, :build_notes,:text
  end
end
