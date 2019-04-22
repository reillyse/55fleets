class AddPodIdToMachines < ActiveRecord::Migration
  def change
    add_column :machines, :pod_id, :integer
  end
end
