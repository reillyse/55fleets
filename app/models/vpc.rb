class Vpc < ActiveRecord::Base

  validates :name ,:presence => true
  belongs_to :app
  has_many :subnets
  has_many :internet_gateways

  state_machine :state, :initial => :created do
    event :starting  do
      transition [:created ] => :starting
    end

    event :activated  do
      transition [:starting ] => :active
    end

    event :shutdown do
      transition [:active,:terminating] => :terminating
    end

    event :terminated do
      transition [:terminating] => :terminated
    end

    event :failed do
      transition any => :failed
    end

  end

  scope :created,  -> { where(:state => ["starting","active"])}

  def kill
    self.shutdown!
    NetworkConfig.new.kill_vpc(self.vpc_id)
    self.terminated!
    save!

  end

  def fetch_subnets
    resp = NetworkConfig.new.get_subnets(self)
    resp.empty? ? (return nil) : (return resp)
  end

  def has_internet_gateway?
    !NetworkConfig.new.get_internet_gateways_for_vpc(self).to_a.empty?
  end

  end
