class AddComposeFilenameToPodConfigs < ActiveRecord::Migration
  def change
    add_column :pod_configs, :compose_filename, :string
  end
end
