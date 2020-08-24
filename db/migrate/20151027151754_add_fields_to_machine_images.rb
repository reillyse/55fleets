class AddFieldsToMachineImages < ActiveRecord::Migration
  def change
    add_column :machine_images, :ami, :string
    add_column :machine_images, :built_at, :datetime

    add_column :pods, :machine_image_id, :integer

    add_column :pods, :git_ref, :string
    add_column :pod_configs, :git_ref, :string
  end
end
