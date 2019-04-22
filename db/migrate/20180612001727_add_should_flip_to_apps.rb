class AddShouldFlipToApps < ActiveRecord::Migration
  def change
    add_column :apps, :should_flip, :boolean
  end
end
