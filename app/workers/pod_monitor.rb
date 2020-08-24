class PodMonitor
  include Sidekiq::Worker
  def perform
    App.all.map do |a|
      a.fleets.where.not(rolling_deploy_completed_at: nil).last
    end.compact.map(
      &:pods
    ).flatten.compact.each(
      &:balance
    )
  end
end
