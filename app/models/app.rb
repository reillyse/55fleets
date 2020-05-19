class App < ActiveRecord::Base

  extend FriendlyId
  friendly_id :name, use: :slugged

  has_many :fleets
  has_many :machines, :through => :fleets
  has_many :builder_machines, :through => :pods, :source => :builder
  has_many :pods
  has_many :env_configs
  has_many :vpcs
  has_many :load_balancers
  has_many :certs
  has_many :ssh_keys
  belongs_to :user

  def init_deploy_key
    SshKey.find_or_create_by_name_and_app(SshKey.deploy_key_name(self),self)
  end

  def deploy_key
    return ssh_keys.where(:name => SshKey.deploy_key_name(self)).first
  end

  belongs_to :repo
  has_and_belongs_to_many :users, :class_name => "User" , :foreign_key => "app_id"
  belongs_to :account
  has_many :fleet_configs

  validates :name, :presence => true, :uniqueness => true

  after_commit :queue_for_setup, :on => :create


  scope :active, -> { where(:active => true)}
  scope :should_flip, -> {where.not(:should_flip => nil)}
  def configured!
    self.state = "configured"
    save!
  end

  def configured?
    self.state == "configured"
  end

  def latest_deployed_fleet
    self.fleets.where.not(:rolling_deploy_completed_at => nil).order("rolling_deploy_completed_at desc").first
  end

  def deployed
    self.active = true
    save!
    #email_deployed_to_owner
  end

  def queue_for_setup
    AppSetup.perform_later(self.id)
  end


  def kill_an_instance machine_id
    Reaper.perform_later machine_id
  end

  def self.build_cache
    return App.find_by_name "build_cache"
  end

  def self.recreate_cache
    begin
      Rails.logger.debug "recreating build system"

      p = build_cache.pods.first
      p.spot_fleet_request.cancel
      p.spot_fleet_request.cancel_machines
      p.spot_fleet_request.update_attribute :pod_id, nil
      p.spot_fleet_request.destroy

    rescue => e
      Rails.logger.debug e.message
    ensure
      PoolManager.create_fleet(ENV["BUILD_MACHINE_POOL_SIZE"] ? ENV["BUILD_MACHINE_POOL_SIZE"].to_i  : 2, build_cache.pods.first,ENV["CACHE_MACHINE_TYPES"] || "t1.micro")

    end

  end

  def self.build_system
    return App.find_by_name "build_system"
  end

  def self.kill_build_system

    build_system.pods.each { |p|
      next unless p.spot_fleet_request
      p.spot_fleet_request.cancel
      p.spot_fleet_request.cancel_machines
      p.spot_fleet_request.update_attribute :pod_id, nil
      p.spot_fleet_request.destroy
    }

  end

  def self.create_build_system
    return false if  App.build_system
    b = App.create! :name => "build_system"
    b.pods.create!

    #self.recreate_build_system
  end

  def self.recreate_build_system

      kill_build_system
      PoolManager.create_fleet(ENV["BUILD_MACHINE_POOL_SIZE"] ? ENV["BUILD_MACHINE_POOL_SIZE"].to_i :  2, build_system.pods.first,ENV["BUILD_MACHINE_TYPES"] || "c4.large")



  end

  def self.change_build_system_ami new_ami
    build_system.pods.first.update_attribute :ami, new_ami
  end

  def for_react
    @fleets = (self.fleets.order("created_at desc").includes(:pods => :machines).limit(20) + self.fleets.with_running_machines.compact).uniq
    return {:fleets => @fleets.map(&:for_react), :id => self.name}
  end
end

# App.build_system.pods.first.machines.map(&:recycle_as_new)
