class AddTypeToRepos < ActiveRecord::Migration
  def change
    add_column :repos, :type, :string
  end
end
