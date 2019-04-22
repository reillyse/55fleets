class RenamePrivateKeyTo < ActiveRecord::Migration
  def change
    add_column :ssh_keys,  :encrypted_private_key, :text
  end
end
