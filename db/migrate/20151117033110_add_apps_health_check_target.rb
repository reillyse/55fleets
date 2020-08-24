class AddAppsHealthCheckTarget < ActiveRecord::Migration
  def change
    add_column :apps, :health_check_target, :string, default: 'HTTP:80/'
  end
end
