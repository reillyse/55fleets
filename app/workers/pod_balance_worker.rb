class PodBalanceWorker
  include Sidekiq::Worker


  def perform pod_id

    pod = Pod.find pod_id
    return unless pod.image_available?

    pod.with_lock('FOR UPDATE NOWAIT') do
      pod.balance
    end

  end
end
