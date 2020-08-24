class CreateErrors < ActiveRecord::Migration
  def change
    create_table :persistant_errors do |t|
      t.string :message
      t.integer :errorable_id
      t.string :errorable_type

      t.timestamps null: false
    end
  end
end
