class AddLoggingUntilToMachines < ActiveRecord::Migration
  def change
    add_column :machines, :logging_until, :datetime
  end
end
