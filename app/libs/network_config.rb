class NetworkConfig
  def client
    return @client ||= Aws::EC2::Client.new
  end

  def get_subnets(vpc)
    resp =
      client.describe_subnets(
        { filters: [{ name: 'vpc-id', values: [vpc.vpc_id] }] }
      )

    return(
      if resp.empty?
        nil
      else
        resp.map(&:subnets).flatten.map do |s|
          [s.subnet_id, s.availability_zone]
        end
      end
    )
  end

  def attach_subnet(vpc_id)
    @vpc = Aws::EC2::Vpc.new vpc_id
    subnet_ids = []
    get_zones.each_with_index do |z, index|
      block = "10.0.#{index + 250}.0/24"
      Rails.logger.debug "trying to create a subnet with CIDR = #{
                           block
                         } in zone #{z} in vpc #{vpc_id}"
      response =
        @vpc.create_subnet cidr_block: block,
                           vpc_id: vpc_id,
                           availability_zone: z

      subnet_id = response.id

      resp =
        client.modify_subnet_attribute(
          {
            subnet_id: subnet_id,
            map_public_ip_on_launch: {
              # required
              value: true
            }
          }
        )

      subnet_ids << [subnet_id, z]
    end

    return subnet_ids
  end

  def create_vpc
    cidr = '10.0.0.0/16'
    response = client.create_vpc cidr_block: cidr

    vpc_id = response.vpc.vpc_id

    client.wait_until :vpc_available, vpc_ids: [vpc_id]
    return vpc_id
  end

  def get_availability_zones
    @availability_zones ||=
      client.describe_availability_zones.availability_zones
  end

  def get_zones
    return get_availability_zones.map(&:zone_name)
  end

  def kill_vpc(vpc_id)
    vpc = Aws::EC2::Vpc.new id: vpc_id
    @vpc = Vpc.find_by_vpc_id(vpc_id)
    unless @vpc.app.load_balancers.empty?
      BalancerService.new.kill_load_balancers(
        @vpc.app.load_balancers.map(&:arn)
      )
    end
    Rails.logger.debug vpc.inspect
    Rails.logger.debug vpc.network_interfaces.map(&:inspect)

    Rails
      .logger.warn 'Sometimes RDS resources are connected and are still in use so we cannot delete them here'
    vpc.network_interfaces.each do |n|
      begin
        n.detach({ force: true })
      rescue StandardError
        next
      end
    end

    vpc.network_interfaces.each do |n|
      begin
        n.unassign_private_ip_addresses(
          {
            private_ip_addresses:
              n.private_ip_addresses.map(&:private_ip_address)
          }
        )
      rescue StandardError
        next
      end
      begin
        n.delete
      rescue StandardError
        next
      end
    end

    vpc.route_tables.each do |rt|
      begin
        rt.delete
      rescue StandardError
        next
      end
    end

    vpc.network_acls.each do |acl|
      begin
        acl.delete
      rescue StandardError
        next
      end
    end

    gateways = vpc.internet_gateways
    gateways.each { |g| vpc.detach_internet_gateway internet_gateway_id: g.id }

    gateways.map(&:delete)

    vpc.subnets.map(&:delete)

    vpc.delete
  end

  def get_internet_gateways_for_vpc(vpc)
    resp = Aws::EC2::Vpc.new(vpc.vpc_id).internet_gateways
  end

  def create_and_attach_internet_gateway(vpc_id)
    resp = client.create_internet_gateway
    internet_gateway_id = resp.internet_gateway.internet_gateway_id
    client.attach_internet_gateway(
      vpc_id: vpc_id, internet_gateway_id: internet_gateway_id
    )
    internet_gateway_id
  end

  def create_new_route(vpc_id, internet_gateway_id)
    @vpc = Aws::EC2::Vpc.new vpc_id
    @vpc.route_tables.first.create_route(
      destination_cidr_block: '0.0.0.0/0',
      # required
      gateway_id: internet_gateway_id
    )
  end

  def change_the_default_security_group(vpc_id)
    @vpc = Aws::EC2::Vpc.new vpc_id
    @vpc.security_groups.first.authorize_ingress cidr_ip: '0.0.0.0/0',
                                                 ip_protocol: :tcp,
                                                 from_port: '22',
                                                 to_port: '22'
  end

  def add_all_traffic_to_load_balancer(load_balancer_arn)
    @lb_client = Aws::ElasticLoadBalancingV2::Client.new
    @load_balancer =
      @lb_client.describe_load_balancers(
        { load_balancer_arns: [load_balancer_arn] }
      ).load_balancers.first
    seg_id = @load_balancer.security_groups.first
    @sec = Aws::EC2::SecurityGroup.new id: seg_id
    begin
      @sec.authorize_ingress cidr_ip: '0.0.0.0/0',
                             ip_protocol: '-1',
                             from_port: '0',
                             to_port: '65535'
    rescue Aws::EC2::Errors::InvalidPermissionDuplicate => e
      Rails.logger.info e.message
    end
  end
end
