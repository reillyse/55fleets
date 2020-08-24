class CreateMachineImages < ActiveRecord::Migration
  def change
    create_table :machine_images do |t|
      t.timestamps null: false
    end
  end
end
