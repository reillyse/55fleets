class SpotFleetRequest < ActiveRecord::Base
  include PersistantErrors

  before_save  :ensure_we_have_a_client_token, :on => :create

  #after_commit :create_the_spot_fleet_request_on_amazon, :on => :create

  scope :active, -> {where(:state => "active")}
  scope :submitted, -> {where(:state => "submitted")}

  has_many :machines
  belongs_to :vpc
  belongs_to :app
  belongs_to :pod

  state_machine :state, :initial => :init do
    event :activate do
      transition any => :active
    end

    event :submit do
      transition any => :submitted
    end

    event :cancelled_terminating! do
      transition any => :cancelled_terminating
    end
    event :cancel do
      transition any => :cancelled
    end

    event :creating do
      transition any => :creating
    end

    event :error do
      transition any => :error_terminated
    end
  end


  def not_active?
    cancelled? || cancelled_terminating? || error_terminated?
  end


  def self.cleanup
    SpotFleetRequest.where(:state => [:cancelled,:cancelled_terminating,:error_terminating,:error_terminated]).each do  |sfr|

      if sfr.machines.running.count > 0
        sfr.cancel_machines
      end

    end
  end

  def cancel_machines
      machines.each { |m| m.terminated!}
  end


  def scale number
    self.instance_count = number
    save!

    if self.instance_count <= 0
      cancel!
      cancel
    else
      SpotFleet.new.scale(spot_fleet_request_id,self.instance_count)
    end
  end


  def ensure_we_have_a_client_token
    self.client_token = "request-id-#{Time.now.strftime('%M %D %Y : %H %m %s')}" if self.client_token.blank?

  end

  def update_my_fleet
    puts "update_my_fleet+"
    self.state = SpotFleet.new.check_spot_fleet_request self.spot_fleet_request_id
    puts "update_my_fleet-"
    save!
  end

  def poll_for_instances

    Timeout::timeout(1200) do
      while true

        get_instances
        sleep(20)
        Rails.logger.debug "Checking."
      end
    end
  end

  def update_instances build_system=false


    puts "get_new_instances+"
    puts "its the build_system ------------------------------" if build_system
    Rails.logger.debug "get_new_instances+"
    puts "Spot Fleet Request == #{self.id}"
    resp = SpotFleet.new.get_spot_fleet_request_instances self.spot_fleet_request_id
    machines  = []
    resp.active_instances.each { |i|
      m = Machine.where(instance_id: i.instance_id, :state => ["created","starting","running"]).first

      if m.nil?
        puts "---------------------------------------------------------------------------------------------------- We havent found an instance with state in_action or running and instance_id"
        puts i.instance_id

        if build_system
          m = BuilderMachine.create! :instance_id => i.instance_id, :pod_id => self.pod.id
        else
          m = SpotMachine.create! :instance_id => i.instance_id, :pod_id => self.pod.id, :instance_type => i.instance_type
          m.started_at = Time.now
          m.starting!
          m.running!
        end
        m.add_tags
        Rails.logger.debug "Added a new spot machine id = #{m.id}"
        m.get_info
        self.machines << m

        if build_system
          m.state = "running"
          m.save!
        else
          m.save!
          Rails.logger.warn "---------------------------------------------------------------------------------------------------- Queueing for deployer from SpotFleetRequest"
          after_transaction do
               Deployer.perform_later m.id
          end
        end
      end

      machines << m


    }
    save!

    (SpotMachine.running.where(:pod_id => pod.id).select(&:deployed_at) - machines.to_a).each { |m|
      Rails.logger.debug "This instance no longer is running machine id = #{m.id}"
      m.shutdown!

    }
    puts "get_new_instances-"
    Rails.logger.debug "get_new_instances-"
  end


  def get_info
    SpotFleet.new.get_spot_fleet_request_info self.spot_fleet_request_id
  end

  def cancel
    resp = SpotFleet.new.cancel(self.spot_fleet_request_id)
    if resp.unsuccessful_fleet_requests.size > 0
      puts resp.unsuccessful_fleet_requests[0].error.message
      puts resp.unsuccessful_fleet_requests[0].spot_fleet_request_id
      puts resp.unsuccessful_fleet_requests[0].error.code
    else
      self.state = resp.successful_fleet_requests[0].current_spot_fleet_request_state
      save!
    end
  end

  def initialize_fleet
    create_the_spot_fleet_request_on_amazon
    self
  end

  def create_the_spot_fleet_request_on_amazon
    resp = SpotFleet.new.create_fleet_request self.client_token, self.instance_count, self.pod, pod.subnets, self.instance_types
    raise "Spot fleet request creation failed" unless resp.spot_fleet_request_id
    self.spot_fleet_request_id = resp.spot_fleet_request_id
    self.update_my_fleet
    save!


  end


  def check_status_of_request
    resp = SpotFleet.new.check_request self.spot_fleet_request_id

  end

  def get_history since_time
    resp = SpotFleet.new.get_history self.spot_fleet_request_id, since_time
  end

  def aws_history
    since_time = self.last_history_check

    history = get_history(since_time).history_records.map {|h|   h.event_information.event_description }
    history.each do |h|
      LogEntry.create! :stdout => "AWS:- " + h , :machine_id => pod.builder.id,:pod_id => pod.id ,:stage => "aws info:"
    end
    self.last_history_check = Time.now
    save!

  end
end
