class DeregisterLoadBalancerWorker < ActiveJob::Base

  queue_as :high

  def perform machine_id
    @machine = Machine.find machine_id
    @machine.load_balancers.each do |elb|
      BalancerService.new.deregister_instance @machine.instance_id,elb.name
    end
  end
end
