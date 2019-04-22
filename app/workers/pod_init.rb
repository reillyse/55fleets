class PodInit < ActiveJob::Base
  queue_as :high

  def perform pod_id
    pod = Pod.find pod_id

    pod.with_lock('FOR UPDATE NOWAIT') do
      pod.initialize_machines
    end
  end
end
