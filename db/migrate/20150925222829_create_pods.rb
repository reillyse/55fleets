class CreatePods < ActiveRecord::Migration
  def change
    create_table :pods do |t|
      t.integer :app_id
      t.text :name
      t.text :compose_command
      t.text :instance_type
      t.text :state
      t.timestamps null: false
    end
  end
end
