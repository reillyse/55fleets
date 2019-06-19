require "aws-sdk-core"

class BalancerService

  def register_instance machine_id, subnet_id =nil, elb_arns

    machine = Machine.find machine_id

    elb = elb_client




    elb_arns.split(",").each {|elb_arn|

      target_group_arn = elb.describe_target_groups
      resp = elb.describe_target_groups({
                                          load_balancer_arn: elb_arn
                                        })
      target_group_arn = resp.target_groups[0].target_group_arn

      elb.register_targets({


                             target_group_arn: target_group_arn,
                             targets: [
                               {
                                 id: machine.instance_id,
                               }
                             ]
                           })

      machine.load_balancers << LoadBalancer.find_by_arn(elb_arn)
      machine.save!
    }



  end



  def elb_client
    @elb_client ||= Aws::ElasticLoadBalancingV2::Client.new
  end

  def rolling_deploy(machines,elb_arns)


    # add the instance
    # wait for it to be up and healthy in the load balancer
    # remove the old instances
    elb = elb_client

    machines.each { |m|

      BalancerService.new.register_instance m.id,nil,elb_arns
    }

    arns = elb_arns.split(",")



    Parallel.each(arns, in_threads: arns.count, progress: "Registering with Load Balancer"){ |elb_arn|
      target_group_arn = get_first_target_group_from_elb_arn elb_arn
      Rails.logger.debug "Waiting for target in service"

      elb.wait_until(:target_in_service,
                     {
                       target_group_arn: target_group_arn


                     })

    }
    Rails.logger.debug "Registered with load balancer"


    elb_arns.split(",").each { |elb_arn|


      registered_instance_ids  = get_instance_ids_from_elb_arn elb_arn

      registered_instance_ids = registered_instance_ids.uniq - machines.map(&:instance_id)

      if registered_instance_ids.size > 0
        puts "deregistering #{registered_instance_ids.to_s}"

        registered_instance_ids.each { |i_id|

          deregister_instance i_id, elb_arn

        }

        ec2 = Aws::EC2::Client.new
        registered_instance_ids.each { |i_id|

          m = Machine.find_by_instance_id i_id
          puts "Balancer Service reaping machine id =#{m.id}"
          Reaper.set(wait_until: 10.seconds.from_now).perform_later(m.id)

        }
      end
    }
  end

  def deregister_instance(i_id, elb_arn)

    m = Machine.find_by_instance_id i_id
    unless m.fleet.deregistered
      m.fleet.deregistered = Time.now
      m.fleet.save!
    end



    target_group_arn = get_first_target_group_from_elb_arn elb_arn
    from_elb = elb_client.deregister_targets({
                                        target_group_arn: target_group_arn,
                                        targets: [
                                          {
                                            id: i_id,
                                          },] })
  end

  def get_targets_from_elb_arn elb_arn
    target_group_arn = get_first_target_group_from_elb_arn elb_arn
    resp = elb_client.describe_target_health({
                                               target_group_arn: target_group_arn,
                                             })


  end

  def get_instance_ids_from_elb_arn elb_arn
    targets = get_targets_from_elb_arn(elb_arn)
    return targets.to_h[:target_health_descriptions].map{|s| s[:target][:id]}
  end

  def get_first_target_group_from_elb_arn elb_arn

    resp = elb_client.describe_target_groups({
                                               load_balancer_arn: elb_arn
                                             })
    target_group_arn = resp.target_groups[0].target_group_arn

    return target_group_arn
  end

  # def deregister_instance machine

  #   machine.load_balancers.each do |lb|
  #     begin
  #       elb_client.deregister_instances_from_load_balancer(load_balancer_name: lb.name,instances: [ { instance_id: machine.instance_id}])
  #       lb.machines.delete(machine)
  #       lb.save!


  #     rescue 	Aws::ElasticLoadBalancing::Errors::LoadBalancerNotFound => e
  #       lb.terminated!
  #       puts e.message
  #       next
  #     end
  #   end
  # end


  def create_new app

    subnet_id = nil

    vpc = app.vpcs.last
    subnets = app.vpcs.last.subnets


    elb_name = "#{app.name}-#{Time.now.to_i}"

    lb =  LoadBalancer.create! :name => elb_name, :app => app

    lb.starting!

    load_balancer = elb_client.create_load_balancer({
                                                      name: elb_name, # required
                                                      #, availability_zones: ["AvailabilityZone"],
                                                      subnets: subnets.map(&:subnet_id)
                                                      #   security_groups: ["SecurityGroupId"],
                                                      #   scheme: "LoadBalancerScheme",
                                                      #   tags: [
                                                      #     {
                                                      #       key: "TagKey", # required
                                                      #       value: "TagValue",
                                                      #     },
                                                      # })
                                                    }).first.load_balancers.first

    lb.arn = load_balancer.load_balancer_arn
    lb.save!
    lb.running!

    target_group  = elb_client.create_target_group({
                                        name: "targets-#{lb.name}"[-30..-1],
                                        port: 80,
                                        protocol: "HTTP",
                                        vpc_id: vpc.vpc_id,
                                        health_check_protocol: "HTTP",
                                        health_check_interval_seconds: 10,
                                        health_check_timeout_seconds: 9,
                                        healthy_threshold_count: 2,
                                        unhealthy_threshold_count: 2,
                                                   }).first.target_groups.first


      elb_client.create_listener({
                               default_actions: [
                                 {
                                   target_group_arn: target_group.target_group_arn,
                                   type: "forward",
                                 },
                               ],
                               load_balancer_arn: load_balancer.load_balancer_arn,
                               port: 80,
                               protocol: "HTTP",
                                 })
      elb_client.create_listener({
                                   default_actions: [
                                     {
                                       target_group_arn: target_group.target_group_arn,
                                       type: "forward",
                                     },
                                   ],
                                   load_balancer_arn: load_balancer.load_balancer_arn,
                                   port: 443,
                                   protocol: "HTTPS",
                                 })

      Rails.logger.debug "#----------------------------------------------------------------------------------------------------"
      Rails.logger.debug load_balancer.inspect
      Rails.logger.debug load_balancer.load_balancer_arn.inspect




    return lb
  end

  def get_url_for_load_balancer lb
    elb = Aws::ElasticLoadBalancingV2::Client.new.describe_load_balancers({load_balancer_arns: [lb.arn],})
    return elb.load_balancers[0].dns_name

  end

  def kill_load_balancers arns

    arns.each { |n|
      elb_client.delete_load_balancer load_balancer_arn: n
    }

  end

  def set_the_certificate load_balancer_name, aws_ssl_cert_id,port = 443

    begin

      resp = elb_client.set_load_balancer_listener_ssl_certificate({
                                                                     load_balancer_name: load_balancer_name, # required
                                                                     load_balancer_port: port, # required
                                                                     ssl_certificate_id: aws_ssl_cert_id, # required

                                                                   })

    rescue Aws::ElasticLoadBalancing::Errors::ListenerNotFound => e
      puts e.message
      puts "attempting to create"

      resp = elb_client.create_load_balancer_listeners({
                                                         load_balancer_name: load_balancer_name,
                                                         listeners: [ # required
                                                           {
                                                             protocol: "HTTPS", # required
                                                             load_balancer_port: port, # required
                                                             instance_protocol: "HTTP",
                                                             instance_port: 80, # required
                                                             ssl_certificate_id: aws_ssl_cert_id,
                                                           },
                                                         ],
                                                       })
    end
  end
end
