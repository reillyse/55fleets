class AddBeforeAndAfterHooksToPodConfigsAndPods < ActiveRecord::Migration
  def change

    add_column :pods, :before_hooks, :text
    add_column :pod_configs, :before_hooks, :text
    add_column :pods, :after_hooks, :text
    add_column :pod_configs, :after_hooks, :text
  end
end
