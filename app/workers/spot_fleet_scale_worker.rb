class SpotFleetScaleWorker

  include Sidekiq::Worker



  def perform pod_id, amount
    pod = Pod.find pod_id
    pod.scale_spot amount
  end
end
