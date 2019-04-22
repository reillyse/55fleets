class AddEncryptedColumnsToRepos < ActiveRecord::Migration
  def change

    add_column :repos, :encrypted_private_deploy_key, :text
    add_column :repos, :encrypted_private_deploy_key_salt, :text
    add_column :repos, :encrypted_private_deploy_key_iv, :text
    remove_column :repos, :private_deploy_key
  end
end
