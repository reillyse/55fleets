class SpotFleet


  def client
    @client ||= Aws::EC2::Client.new
  end

  def create_fleet_request client_token,target_capacity,pod,subnets,instance_types = "r5.large, m5.large, c4.large, c5.large",spot_price = "0.1",allocation_strategy = "diversified"


    #iam_fleet_role = "arn:aws:iam::547832388282:role/spot-fleet-role"
    iam_fleet_role = Roles.new.find_or_create_spot_fleet_role.arn

    if pod.nil? || pod.ami.nil?
      ami_image = ENV["default_ami"]
    else
      ami_image = pod.ami
    end

    launch_configs =[]

    instance_types = "m4.large, m5.large" if instance_types.blank?
   # instance_types =  "m3.medium, m1.large,c1.medium" #"m1.large, m1.xlarge,  m3.large, m3.xlarge,m2.xlarge,c1.medium, c1.xlarge, c3.large, c3.xlarge, r3.large, r3.xlarge, m3.medium, d2.xlarge"

    instance_types.split(",").map(&:strip).sort{rand}.each { |it|

      subnets.each do |subnet|
        launch_configs << SpotFleet.launch_config_with_type(it,spot_price,ami_image,subnet.subnet_id,pod.app.deploy_key.name)
      end

    }

    Rails.logger.debug iam_fleet_role
    Rails.logger.debug "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"

    resp = client.request_spot_fleet({
                                       spot_fleet_request_config: { # required
                                         client_token: client_token,
                                         spot_price: spot_price, # required
                                         target_capacity: target_capacity, # required
                                         terminate_instances_with_expiration: true,
                                         iam_fleet_role: iam_fleet_role, # required
                                         launch_specifications: launch_configs,
                                         excess_capacity_termination_policy: "Default", # accepts noTermination, default
                                         allocation_strategy: allocation_strategy,
                                       },
                                     })

  end



  # accepts t1.micro, m1.small, m1.medium, m1.large, m1.xlarge, m3.medium, m3.large, m3.xlarge, m3.2xlarge, m4.large, m4.xlarge, m4.2xlarge, m4.4xlarge, m4.10xlarge, t2.micro, t2.small, t2.medium, t2.large, m2.xlarge, m2.2xlarge, m2.4xlarge, cr1.8xlarge, i2.xlarge, i2.2xlarge, i2.4xlarge, i2.8xlarge, hi1.4xlarge, hs1.8xlarge, c1.medium, c1.xlarge, c3.large, c3.xlarge, c3.2xlarge, c3.4xlarge, c3.8xlarge, c4.large, c4.xlarge, c4.2xlarge, c4.4xlarge, c4.8xlarge, cc1.4xlarge, cc2.8xlarge, g2.2xlarge, cg1.4xlarge, r3.large, r3.xlarge, r3.2xlarge, r3.4xlarge, r3.8xlarge, d2.xlarge, d2.2xlarge, d2.4xlarge, d2.8xlarge

  def self.launch_config_with_type instance_type,spot_price,ami_image,subnet_id,deploy_key
    return       {
      image_id: ami_image,
      instance_type: instance_type,
      key_name:  deploy_key,
      subnet_id: subnet_id

    }
  end


  def scale spot_fleet_request_id, size

    resp = client.modify_spot_fleet_request({
                                              spot_fleet_request_id: spot_fleet_request_id, # required
                                              target_capacity: size,
                                              excess_capacity_termination_policy: "Default", # accepts noTermination, default
                                            })
  end


  def cancel spot_fleet_request_id
    resp = client.cancel_spot_fleet_requests({
                                               spot_fleet_request_ids: [spot_fleet_request_id],
                                               terminate_instances: true
                                             })

  end

  def check_spot_fleet_request spot_fleet_request_id
    resp = client.describe_spot_fleet_requests({
                                                 spot_fleet_request_ids: [spot_fleet_request_id]
                                               })

    return resp.spot_fleet_request_configs.first.spot_fleet_request_state
  end

  def get_spot_fleet_request_info spot_fleet_request_id
    resp = client.describe_spot_fleet_requests({
                                                 spot_fleet_request_ids: [spot_fleet_request_id]
                                               })

    return resp
  end

  def get_spot_fleet_request_instances spot_fleet_request_id
    resp = client.describe_spot_fleet_instances({
                                                  spot_fleet_request_id: spot_fleet_request_id
                                                })

    return resp
  end


end
