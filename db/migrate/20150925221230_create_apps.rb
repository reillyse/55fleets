class CreateApps < ActiveRecord::Migration
  def change
    create_table :apps do |t|
      t.integer :user_id
      t.text :name
      t.integer :account_id
      t.integer :repo_id
      t.timestamps null: false
    end
  end
end
