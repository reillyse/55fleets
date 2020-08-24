class AddRepoIdToPods < ActiveRecord::Migration
  def change
    add_column :pods, :repo_id, :integer
  end
end
