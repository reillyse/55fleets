class AddNumberOfMembersToPods < ActiveRecord::Migration
  def change
    add_column :pods, :number_of_members, :integer
  end
end
