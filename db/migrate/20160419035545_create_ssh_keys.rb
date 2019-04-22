class CreateSshKeys < ActiveRecord::Migration
  def change
    create_table :ssh_keys do |t|
      t.integer :app_id
      t.text :user_id
      t.text :public_key
      t.boolean :active
      t.text :encrypted_private_key
      t.text :encrypted_private_key_iv

      t.timestamps null: false
    end
  end
end
