class ChangeMachinesBusyToDatetime < ActiveRecord::Migration
  def change
    remove_column :machines, :busy
    add_column :machines, :busy, :datetime
  end
end
