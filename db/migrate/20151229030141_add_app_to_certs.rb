class AddAppToCerts < ActiveRecord::Migration
  def change
    add_column :certs, :app_id, :integer
    add_column :certs, :user_id, :integer
  end
end
