class AddRepoIdToPodConfigs < ActiveRecord::Migration
  def change
    add_column :pod_configs, :repo_id, :integer    
  end
end
