class AddComposeFilenameToPod < ActiveRecord::Migration
  def change
    add_column :pods, :compose_filename, :string
  end
end
