class CreateFleets < ActiveRecord::Migration
  def change
    create_table :fleets do |t|
      t.timestamps null: false
    end
  end
end
