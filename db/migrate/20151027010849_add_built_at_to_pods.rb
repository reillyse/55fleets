class AddBuiltAtToPods < ActiveRecord::Migration
  def change
    add_column :pods, :built_at, :datetime
  end
end
