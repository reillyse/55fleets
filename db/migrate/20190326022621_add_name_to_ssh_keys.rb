class AddNameToSshKeys < ActiveRecord::Migration
  def change
    add_column :ssh_keys, :name, :text
  end
end
