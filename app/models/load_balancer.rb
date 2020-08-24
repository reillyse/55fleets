class LoadBalancer < ActiveRecord::Base
  has_many :certificate_load_balancers
  has_many :certs, through: :certificate_load_balancers

  scope :active, -> { where(state: 'running') }
  belongs_to :app
  has_and_belongs_to_many :machines

  state_machine :state, initial: :created do
    event :starting do
      transition %i[created] => :starting
    end

    event :running do
      transition %i[starting] => :running
    end

    event :shutdown do
      transition %i[running] => :terminating
    end

    event :terminated do
      transition %i[terminating] => :terminated
    end

    event :failed do
      transition any => :failed
    end

    after_transition on: :running, do: :get_url
  end

  def get_url
    self.url = BalancerService.new.get_url_for_load_balancer self
    save!
  end

  def kill
    BalancerService.new.kill_load_balancers [self.name]
  end

  def add_machine(machine)
    BalancerService.new.register_instance machine.id, nil, self.arn
  end

  def update_certs
    certs.each do |c|
      BalancerService.new.set_the_certificate(
        self.name,
        c.aws_ssl_cert_id,
        c.port
      )
    end
  end

  def url_with_protocol
    return "https://#{self.url}" if certs.size > 0
    return "http://#{self.url}"
  end
end
