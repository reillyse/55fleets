class AddSecretKeyToRepos < ActiveRecord::Migration
  def change
    add_column :repos, :secret_key, :string
  end
end
