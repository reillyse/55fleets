class AddBuilderIdToPods < ActiveRecord::Migration
  def change
    add_column :pods, :builder_id, :integer
  end
end
