class Instance
  #creates an instance and returns an ip address for us

  # def self.create_spot_instance instance_type,vpc, ami = "ami-9a6520f0"
  #   @client = Aws::EC2::Client.new

  #   instance_type = "c4.large"

  #   instance = { instance_type: instance_type,  image_id: ami,  key_name: "gsg-keypair"}
  #   Rails.logger.debug "Creating instance #{instance.inspect}"
  #   response = @client.request_spot_instances( launch_specification: instance, spot_price: "0.05", type: "one-time")

  #   request_id  = response.spot_instance_requests[0].spot_instance_request_id

  #   begin
  #     @client.wait_until(:spot_instance_request_fulfilled, spot_instance_request_ids: [request_id])
  #   rescue Aws::Waiters::Errors::FailureStateError => e
  #     Rails.logger.debug e.message
  #     raise e
  #   end

  #   instant = @client.describe_spot_instance_requests({instance_ids: [i_id]})
  #   instance_id = instant.spot_instance_requests[0].instance_id

  #   #    Rails.logger.debug instant.reservations.first.instances.first.network_interfaces.first
  #   aws_instance = Aws::EC2::Instance.new(instance_id,@client)
  #   ip_address = aws_instance.network_interfaces.first.association.public_ip

  #   return ip_address,i_id

  # end

  def self.create_instance(instance_type, vpc, subnet_id, ami = 'ami-63331109')
    Rails.logger.debug "creating an instance with instance_type=#{
                         instance_type
                       }, vpc = #{vpc}, subnet_id = #{subnet_id}, ami = #{ami}"
    @vpc = Vpc.find_by_vpc_id vpc
    @client = Aws::EC2::Client.new

    instance = {
      instance_type: instance_type,
      min_count: 1,
      max_count: 1,
      image_id: ami,
      subnet_id: subnet_id,
      key_name: @vpc.app.deploy_key.name
    }
    Rails.logger.debug "Creating instance #{instance.inspect}"
    i = @client.run_instances instance

    new_instance = i.instances.first

    i_id = new_instance.instance_id
    begin
      @client.wait_until(:instance_running, instance_ids: [i_id])
    rescue Aws::Waiters::Errors::FailureStateError => e
      Rails.logger.debug e.message
      raise e
    end

    instant = @client.describe_instances({ instance_ids: [i_id] })
    #network_interface = @client.create_network_interface(subnet_id: subnet_id).network_interface

    #@client.attach_network_interface(instance_id: i_id, network_interface_id: network_interface.network_interface_id,device_index: 1)
    #@client.wait_until(:network_interface_available, network_interface_ids: [network_interface.network_interface_id])
    # no idea what device-index is
    #ip_address = network_interface.association.public_ip
    #can get private ip very easy here too

    Rails.logger.debug instant.reservations.first.instances.first
                         .network_interfaces.first
    ip_address =
      instant.reservations.first.instances.first.network_interfaces.first
        .association.public_ip

    return ip_address, i_id
  end

  def self.terminate_instance(instance_id)
    ec2 = Aws::EC2::Client.new

    ec2.terminate_instances({ instance_ids: [instance_id] })
  end

  def self.get_instance_info(instance_id)
    @client = Aws::EC2::Client.new
    resp = @client.describe_instances({ instance_ids: [instance_id] })
    return false unless resp.reservations[0]
    return resp.reservations[0].instances[0]
  end

  def self.tag_instance(instance, tag)
    @client = Aws::EC2::Client.new
    resp =
      @client.create_tags(
        {
          resources: [instance],
          tags: [
            {
              # required
              # required
              key: tag.first.first,
              value: tag.first.second
            }
          ]
        }
      )
  end
end
