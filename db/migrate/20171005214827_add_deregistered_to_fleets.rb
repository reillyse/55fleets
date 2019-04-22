class AddDeregisteredToFleets < ActiveRecord::Migration
  def change
    add_column :fleets, :deregistered, :datetime
  end
end
