class FleetChecker 
  include Sidekiq::Worker

  def perform
    App.active.each do |a|
      
      fleet = a.latest_deployed_fleet
      next unless fleet
      fleet.pods.each do |pod|
        PodBalanceWorker.perform_async pod.id
        pod.balance
      end
    end
  end
  
end
