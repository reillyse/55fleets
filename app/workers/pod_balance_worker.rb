class PodBalanceWorker
  include Sidekiq::Worker

  def perform(pod_id)
    pod = Pod.find pod_id
    return unless pod.image_available?

    pod.with_lock('FOR UPDATE NOWAIT') { pod.balance }
  end
end
