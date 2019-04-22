class AddSpotAmountToPods < ActiveRecord::Migration
  def change
    add_column :pods, :spot_amount, :int
    add_column :pods, :spot_type, :text
    add_column :pods, :spot_bid, :string
  end
end
