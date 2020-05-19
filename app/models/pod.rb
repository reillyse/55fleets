class Pod < ActiveRecord::Base
  include PersistantErrors

  has_many :machines
  has_many :spot_machines
  has_many :builder_machines
  has_many :on_demand_machines
  has_many :env_configs
  belongs_to :app, :touch => true
  belongs_to :fleet, :touch => true
  belongs_to :repo
  belongs_to :builder, :class_name => "Machine"
  has_one :spot_fleet_request
  #after_commit :initialize_machines, :on => :create
  after_commit :build_pod, :on => :create
  after_touch :touch_app

  def touch_app
    self.app.touch if self.app
    self.fleet.touch if self.fleet
  end

  validates :app_id, :presence => true

  state_machine :state, :initial => :created do

    event :build  do
      transition [:created ] => :built
    end

    event :imaging_started do
      transition [:built] => :imaging
    end

    event :imaged do
      transition [:imaging] => :image_available
    end

    event :back_to_built do
      transition [:imaging,:imaged] => :built
    end


    event :shutdown do
      transition [:running] => :terminating
    end

    event :terminated do
      transition [:terminating] => :terminated
    end

    event :clean_up do
      transition :image_available => [:cleaned_up]
    end
    #before_transition any => :built, :do => :build_image
    after_transition any => :built, :do => :create_image

  end

  def create_image
    Imager.perform_async(self.id)
  end

  def log_command
    if self.compose_filename.blank?
      return "docker-compose logs"
    else
      return "docker-compose -f #{self.compose_filename} logs"
    end
  end

  def balance
    #don't need to scale spot
    # if self.fleet.deregistered || !self.fleet.is_most_recent?
    #   Rails.logger.debug "fleet degisterred (#{self.fleet.deregistered}) or not most recent (#{!self.fleet.is_most_recent?})"
    #   return scale_down_permanent(0) # we are done
    # end


    current_on_demand_machines = self.on_demand_machines.operating.count

    if current_on_demand_machines < self.permanent_minimum
      Rails.logger.debug "Scaling up permanent to #{self.permanent_minimum}"
      scale_up_permanent(self.permanent_minimum)

    elsif current_on_demand_machines > self.permanent_minimum
      Rails.logger.debug "Scaling down permanent minimum to #{self.permanent_minimum}"
      scale_down_permanent(self.permanent_minimum)
    end
  end



  def build_pod
    ImageBuilder.perform_later(self.id)
  end

  def initialize_machines


    number_of_spots = self.number_of_members - (self.permanent_minimum || 0)

    number_of_machines_to_add = (self.permanent_minimum || 0) - self.on_demand_machines.running.count
    add_on_demand_machines number_of_machines_to_add if number_of_machines_to_add > 0

    if self.spot_fleet_request.nil?

      get_spot_machines(number_of_spots) if number_of_spots > 0

    end


  end

  def get_spot_machines instance_count
    Rails.logger.debug "Getting spot machines"

    self.spot_fleet_request = PoolManager.create_fleet instance_count,self,self.instance_type
    save!
    spot_fleet_request.update_my_fleet
  end


  def add_on_demand_machines instance_count

    return unless instance_count && instance_count > 0
    Rails.logger.debug "Should make some machines"
    new_machines = []

    instance_count.times { new_machines << self.on_demand_machines.create!(:instance_type => self.instance_type,:subnet_id => next_subnet.id )}
    new_machines.each { |machine|
      after_transaction do
        Birther.perform_later(machine.id)
      end
    }
  end

  def remove_on_demand_machines instance_count
    Rails.logger.debug "removing #{instance_count} on_demand_machines"
    return unless instance_count && instance_count > 0
    machines = self.on_demand_machines.running
    instance_count.times { |ic| machines[ic].shutdown! }
  end


  def scale_permanent value
    if value > self.permanent_minimum
      scale_up_permanent value
    elsif
      value < self.permanent_minimum
      scale_down_permanent value
    else
      Rails.logger.debug "no change"
    end


  end

  def scale_up_permanent value
    self.permanent_minimum = value

    save!

    self.with_lock('FOR UPDATE NOWAIT') do
      current_count = self.on_demand_machines.running.count
      number_to_be_added  = value - current_count

      add_on_demand_machines number_to_be_added

      save!
    end

  end

  def scale_down_permanent value
    self.permanent_minimum = value

    save!

    self.with_lock('FOR UPDATE NOWAIT') do
      current_count = self.on_demand_machines.running.count
      number_to_be_removed  = current_count - value

      remove_on_demand_machines number_to_be_removed

      save!
    end

  end


  def scale_spot value
    Rails.logger.debug "Scaling spot"
    self.spot_amount = value
    save!

    if self.spot_fleet_request.nil? || self.spot_fleet_request.not_active?
      get_spot_machines(spot_amount) if spot_amount > 0
    else
      self.spot_fleet_request.scale(self.spot_amount)
    end
  end




  # here is where we put the subnet selection logic
  # we can disperse across availability zones if we want
  def subnets
    self.app.vpcs.last.subnets
  end

  def next_subnet excluded_subnets=[]

    subnet_count = (subnets - excluded_subnets).each_with_object(Hash.new(0)) { |s,count| count[s] = s.machines.running.count }
    subnet_count.sort_by { |subnet,count| count}.first.first

  end

  def cleanup_ami
    begin
      Image.new.delete_ami self.ami
      self.clean_up!
    rescue Aws::EC2::Errors::InvalidAMIIDUnavailable => e1
      self.clean_up!
    rescue Aws::EC2::Errors::ServiceError => e
      Rails.logger.debug e.message
    end
  end
end
