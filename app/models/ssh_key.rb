class SshKey < ActiveRecord::Base

  attr_encrypted :private_key, :key => ENV["GSG_KEY_SECRET"], algorithm: 'aes-256-cbc', mode: :single_iv_and_salt, insecure_mode: true


  def self.create_key name
    return KeyService.new.create_new_key_pair name
  end

  def self.create_deploy_key app
    key = create_key deploy_key_name(app)
    return app.ssh_keys.create! :name => "deploy_key_fleet#{app.id}", :private_key => key.key_material, :public_key => key.key_fingerprint
  end

  def self.create_access_key app
    key = create_key "access_key#{app.id}"
    return app.ssh_keys.create! :name => "access_key_fleet#{app.id}", :private_key => key.key_material, :public_key => key.key_fingerprint
  end

  def self.create_new_key name, app
    key = create_key  name
    sshkey =  app.ssh_keys.create! :name => name,  :public_key => key.key_fingerprint
    sshkey.private_key = key.key_material
    sshkey.save!
  end

  def self.deploy_key_name app
    return "deploy-key-#{app.name}-#{app.id}-#{app.created_at.to_i}"
  end

  def self.find_or_create_by_name_and_app name,app
    key_name = deploy_key_name app
    key = app.ssh_keys.where(:name => key_name)

    if key.empty?
      return create_new_key key_name,app
    else
      return key.first
    end
  end

  belongs_to :app


  #The entire app has a key used for deploying
  #We add the users key to the machines so they can log in

end
