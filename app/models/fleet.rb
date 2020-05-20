class Fleet < ActiveRecord::Base
  has_many :pods
  belongs_to :app, :touch => true
  has_many :machines, :through => :pods
  belongs_to :fleet_config

  scope :with_running_machines, -> {joins(:pods,:machines).where("machines.state" => [:running, :in_action])}
  scope :deployed, -> {where.not(:rolling_deploy_completed_at => nil)}

  def launch fleet_config


    fleet_config.pod_configs.each { |p|

      self.pods.create! :repo => p.repo, :compose_command => p.compose_command, :name => p.name, :number_of_members => p.number_of_members, :instance_type =>  p.instance_type, :app => self.app, :load_balanced => p.load_balanced, :compose_filename => p.compose_filename, :before_hooks => p.before_hooks, :after_hooks => p.after_hooks, :build_command => p.build_command, :git_ref => p.git_ref, :permanent_minimum => p.permanent_minimum, :spot_amount => p.number_of_members - p.permanent_minimum


    }


  end

  def is_most_recent?
    return self.app.fleets.deployed.order("rolling_deploy_completed_at desc").first == self
  end

  def roll_if_deployed
    Fleet.transaction do
      me = self
      me.lock!('FOR UPDATE NOWAIT')
      return false unless me.rolling_deploy_started_at.nil?
      machines = me.machines.select { |m| m.pod.load_balanced? }
      return false unless machines.all?(&:running?)
      RollingDeploy.perform_later(me.id)
      save!
    end
  end

  def deploy_if_built
    Fleet.transaction do
      me = self
      me.lock!('FOR UPDATE NOWAIT')
      return false unless me.pods.all?(&:built_at)
      # create all the machines
      # deploy all the builds
    end
  end

  def cleanup_when_finished
    self.pods.map(&:machines).flatten.select(&:running?).each {|m|
      m.shutdown!
    }
    self.pods.map(&:spot_fleet_request).compact.select(&:active?).map(&:cancel!)
  end

  def post_deploy_hook

  end

  def relaunch_this_fleet
    fleet = Fleet.create! :app => self.app, :fleet_config => self.fleet_config
    FleetLauncher.perform_later(fleet.id,self.fleet_config.id)
  end

  def redeploy_this_fleet
    fleet = self
    @new_fleet = fleet.dup
    @new_fleet.pods = fleet.pods.map(&:dup)
    @new_fleet.rolling_deploy_started_at  = nil
    @new_fleet.rolling_deploy_completed_at  = nil
    @new_fleet.save!
    @new_fleet.pods.each do |pod|
      PodInit.perform_later pod.id
    end
  end

  def for_react

    return self.as_json.merge(:pods => self.pods.order(:id).map{ |p| p.as_json }, :machines => self.machines.order(:id).map{ |m| m.as_json(:include => [:pod,:subnet]) }, :running_count => self.machines.running.count, :appName => self.app.name, :appID => self.app.id)
  end
end
