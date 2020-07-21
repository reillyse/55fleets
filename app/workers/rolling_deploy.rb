class RollingDeploy < ActiveJob::Base

  queue_as :high

  def perform fleet_id
    fleet = Fleet.find fleet_id
    @app = fleet.app
    Rails.logger.debug "Before BalancerService"

    Fleet.transaction do
      fleet.lock!('FOR UPDATE NOWAIT')
      return "weve already started this deploy" unless fleet.rolling_deploy_started_at.nil?

      machines = fleet.machines.select { |m| m.pod.load_balanced? }
      Rails.logger.warn "pods not all built" and return unless fleet.pods.all?{ |p| p.image_available?}
      

      #we only care about having enough running machines not that they are all running
#      return "machines not all running" unless machines.all?(&:running?)
#      return "machines not all deployed"  unless machines.all?{ |m| m.deployed_at}
      Rails.logger.warn  "we dont have the amount of machines we need" and return  unless fleet.pods.select(&:load_balanced?).all?{ |p| p.machines.select(&:deployed_at).count >= p.permanent_minimum }

      fleet.rolling_deploy_started_at = Time.now
      fleet.save!
    end

    Timeout.timeout(ENV["LB_TIMEOUT"] ||  1200 ) do

      BalancerService.new.rolling_deploy(fleet.machines.select{|m| m.pod.load_balanced},fleet.app.load_balancers.active.map(&:arn).join(","))
    end
    @app = @app.reload
    Rails.logger.debug "After BalancerService"
    @app.pods.where("fleet_id < ?",fleet.id).map(&:spot_fleet_request).compact.select{|s| s.state == "active"}.map(&:cancel)
    #we only kill older machines
    all_machines = @app.machines.joins(:fleet).where("fleets.id < ?" ,fleet.id).reject { |m| m.pod.load_balanced}.reject { |m| m.terminated?}
    fleets = all_machines.map(&:fleet).uniq

    active_machines = fleet.machines.reject { |m| m.pod.load_balanced }

    fleet.rolling_deploy_completed_at = Time.now
    fleet.app.deployed
    fleet.save!
    fleets.each { |f| f.cleanup_when_finished }

    (all_machines - active_machines).each { |m|
      Rails.logger.debug "queueing for reaping of old machines"
      Rails.logger.debug m.id

        Reaper.perform_later(m.id)

    }





  rescue => e
    fleet.rolling_deploy_started_at = nil
    fleet.save!
    raise e
  end

end
