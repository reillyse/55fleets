class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.text :name
      t.timestamps null: false
    end
  end
end
