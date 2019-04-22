class CreateRepos < ActiveRecord::Migration
  def change
    create_table :repos do |t|
      t.string :repo_name
      t.text :url
      t.text :public_deploy_key
      t.text :private_deploy_key
      t.integer :user_id      
      t.timestamps null: false
    end
  end
end
