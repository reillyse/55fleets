class AppSetup < ActiveJob::Base
  queue_as :high

  def perform(app_id, create_lb = true)
    @app = App.find(app_id)

    create_lb = false if App.build_system == @app
    #raise "App already setup" unless @app.vpcs.empty?
    @network = NetworkConfig.new
    if @app.vpcs.created.size == 0
      vpc = @app.vpcs.create! name: "#{@app.name}-vpc"
      vpc.starting!
      vpc_id = @network.create_vpc
      vpc.vpc_id = vpc_id
    else
      vpc = @app.vpcs.last
    end

    subnets = vpc.fetch_subnets || @network.attach_subnet(vpc.vpc_id)

    subnets.each do |subnet|
      vpc.subnets.create! subnet_id: subnet.first,
                          availability_zone: subnet.second
    end
    vpc.save!
    vpc.activated! unless vpc.active?
    if !vpc.has_internet_gateway?
      internet_gateway_id =
        @network.create_and_attach_internet_gateway vpc.vpc_id

      route = @network.create_new_route vpc_id, internet_gateway_id
      vpc.internet_gateways.create! internet_gateway_id: internet_gateway_id

      @network.change_the_default_security_group vpc_id
    end
    @app = App.find @app.id

    if create_lb
      if @app.load_balancers.last
        balancer = @app.load_balancers.last
      else
        balancer = BalancerService.new.create_new @app
      end
      @network.add_all_traffic_to_load_balancer balancer.arn
    end

    @app.init_deploy_key
    @app.configured!
  end
end
