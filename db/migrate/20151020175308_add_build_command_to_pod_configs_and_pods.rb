class AddBuildCommandToPodConfigsAndPods < ActiveRecord::Migration
  def change

    add_column :pod_configs, :build_command, :string
    add_column :pods, :build_command, :string
  end
end
