class ChangeTheShouldFlipToADate < ActiveRecord::Migration
  def change
    remove_column :apps, :should_flip, :boolean
    add_column :apps, :should_flip, :integer, default: 300
  end
end
