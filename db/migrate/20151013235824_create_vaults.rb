class CreateVaults < ActiveRecord::Migration
  def change
    create_table :vaults do |t|
      t.text :encrypted_data
      t.string :name
      t.text :encrypted_data_salt
      t.text :encrypted_data_iv
      t.timestamps null: false
    end
  end
end
