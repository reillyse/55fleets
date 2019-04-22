class Repo < ActiveRecord::Base

  attr_encrypted :private_deploy_key, :key => ENV["REPO_KEY_SECRET"], :mode => :per_attribute_iv_and_salt
  before_create :generate_ssh_deploy_key
  before_create :generate_secret_key
  
  belongs_to :user
  has_one :app
  has_many :pods
  has_many :machines, :through => :pods

  def generate_secret_key
    self.secret_key = SecureRandom.hex
  end
  
  def generate_ssh_deploy_key

    k =  SSHKey.generate
    self.public_deploy_key = k.ssh_public_key
    self.private_deploy_key = k.private_key
    
  end

  def add_key
    raise "need to be implemented in subclass"
  end

  def add_url
    raise "need to be implemented in subclass"
  end
end
