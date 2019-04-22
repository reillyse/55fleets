class AddActiveDeployToApps < ActiveRecord::Migration
  def change
    add_column :apps, :active, :boolean
  end
end
