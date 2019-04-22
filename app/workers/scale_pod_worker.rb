class ScalePodWorker < ActiveJob::Base

  queue_as :high

  def perform pod_id
    pod = Pod.find pod_id
    pod.balance
  end
  
end
