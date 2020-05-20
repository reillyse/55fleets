class Machine < ActiveRecord::Base

  include RealTimeLogger

  belongs_to :subnet

  validates_uniqueness_of :ip_address, :scope => [:state], :if =>  Proc.new {|m| Rails.logger.debug "---------------------------------------------------------------------------------------------------- checking ip_address = m.ip_address"
    m.running?
  }

  has_and_belongs_to_many :load_balancers

  has_one :app, :through => :pod
  belongs_to :pod, :touch => true
  has_one :fleet, :through => :pod
  state_machine :state, :initial => :created do
    event :starting  do
      transition [:created ] => :starting
    end

    event :running  do
      transition [:starting ] => :running
    end

    event :deployed do
      transition any => :running
    end

    event :shutdown do
      transition any => :terminating
    end

    event :terminated do
      transition any => :terminated
    end

    event :failed do
      transition any => :failed
    end

    event :recycle do
      transition any => :recycled
    end

    after_transition any => :terminating , do: :queue_for_reaping
    after_transition any => :terminated, do: :deregister_from_load_balancer
    after_transition any => :running, do: :add_tags
  end

  def deregister_from_load_balancer
    DeregisterLoadBalancerWorker.perform_later self.id
    Rails.logger.debug "Finished queueing the deregister from load balancer, should be good"
  end

  def queue_for_reaping
    Rails.logger.debug "Not reaping spot machines" and return if self.is_a?  SpotMachine
    Reaper.perform_later self.id
  end


  scope :running, -> { where(:state => [:running, :in_action])}
  scope :starting, -> { where(:state => :starting) }
  scope :operating, -> { where(:state => [:running, :in_action, :starting, :created])}
  scope :free, -> { where(:busy => [nil]) }
  scope :busy, -> { where.not(:busy => [nil]) }

  def log message, stage="system"
    LogEntry.create! :stdout =>  message , :machine_id => self.id,:pod_id => pod ? pod.id : nil ,:stage => stage
  end

  def free?
    !self.busy
  end

  def free!
    self.busy = nil
    self.save!
  end

  def clear_old_docker_images

    t = Terminal.new self
    begin
      #      t.connect ["docker rmi `docker images | awk '{ print $3; }'`","docker rm `docker ps -a -q`"," docker images -f dangling=true -q | xargs -r docker rmi"]
      t.connect ["df -h","docker rmi -f `docker images | awk '{ print $3; }'`", "df -h"]
    rescue FailedCommandException => e
      Rails.logger.debug e.message + " ... continuing"
      #we fail here when we have no docker containers to delete
    end

    begin
      t.connect ["df -h","docker images -f dangling=true -q | xargs -r docker -f rmi", "df -h"]
    rescue FailedCommandException => e
      Rails.logger.debug e.message + " ... continuing"
    end

    begin
      t.connect ["docker ps -q -a | xargs docker rm","df -h"]
    rescue FailedCommandException => e
      Rails.logger.debug e.message + " ... continuing"
    end

  end


  def clean_deploy_dir

    t = Terminal.new self
    t.connect ["rm -rf deploy","rm -rf deploy_key","rm -rf .git"]
  end

  # def self.birth app_id

  #   app = App.find app_id
  #   macine = app.machines.create! :instance_type => instance_type

  #   Birther.perform_later machine.id, app.id, app.vpcs.first.id
  # end

  # creates the instance on EC2
  # this is slow because we need to wait
  def add_tags
    Instance.tag_instance self.instance_id, :environment => Rails.env if Rails.env
    Instance.tag_instance self.instance_id, :app => self.app.name if self.app.name
    Instance.tag_instance self.instance_id, :pod => self.pod.name if self.pod.name
  end

  def create_instance
    raise "Machine needs to be in created state" unless self.created?
    self.started_at = Time.now
    vpc = self.pod.app.vpcs.first

    begin

      self.ip_address,self.instance_id  = Instance.create_instance self.instance_type, vpc.vpc_id, self.subnet.subnet_id, self.pod.ami

    rescue Aws::EC2::Errors::Unsupported => e
      retry_count ||= 3
      excluded_subnets ||= []
      excluded_subnets << self.subnet
      if retry_count > 0
        retry_count = retry_count - 1
        self.subnet = self.pod.next_subnet(excluded_subnets)
        save!
        retry
      end
    end
    save!

    Rails.logger.warn "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ Queueing for Deployer in Machine"
    Deployer.perform_later(self.id)
  end

  def kill_instance
    raise "Machine needs to be in terminating state" unless self.terminating? || self.terminated?
    self.stopped_at = Time.now
    save!

    log("Machine Terminated")

    begin
      Instance.terminate_instance self.instance_id if self.instance_id
    rescue Aws::EC2::Errors::InvalidInstanceIDNotFound => e
      Rails.logger.debug e.message
      log("On Demand Machine Terminating error #{e.message}")
    end
  end

  def check_aws_status

    begin

      return false unless self.running?
      info = Instance.get_instance_info self.instance_id
      if info == false
        logger.debug "info is false we are terminating the machine #{self.id}"
        return self.terminated!
      end


      logger.debug "locked the machine object #{self.id}"
      case info.state.name

      when "running"
        logger.debug "the machine is running"
        return running! unless self.running?
      when "terminated" , "cancel-terminating"
        logger.debug "AWS says this machine is #{info.state.name}"
        Rails.logger.debug "state is in a terminating state - #{info.state.name}"
        terminated! unless self.terminated!
      end
    rescue Aws::EC2::Errors::InvalidInstanceIDNotFound => e
      Rails.logger.debug "We can't find the instance so going to terminate"
      self.terminated!
    end
  end

  def self.get_free_builder_machine app
    return BuilderMachine.get_free_builder_machine
  end

  def get_info
    info = Instance.get_instance_info self.instance_id
    Rails.logger.debug info.inspect
    Rails.logger.debug "here"
    self.ip_address = info.public_ip_address
    self.instance_type = info.instance_type
    self.subnet = Subnet.find_by_subnet_id info.subnet_id
    save!
  end

end
