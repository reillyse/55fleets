class PodMonitor
  include Sidekiq::Worker
  def perform
    App.all.map { |a| a.fleets.where.not(:rolling_deploy_completed_at => nil).last}.compact.map{ |p| p.pods}.flatten.compact.each do |pod|
      pod.balance
    end
  end
end
