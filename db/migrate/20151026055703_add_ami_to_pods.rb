class AddAmiToPods < ActiveRecord::Migration
  def change
    add_column :pods, :ami, :string
  end
end
