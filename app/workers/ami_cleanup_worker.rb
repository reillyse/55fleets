#TODO class to cleanup old AMIs that are no longer being used

class AmiCleanupWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :low

  def perform
    Pod.where(:state => "image_available").where("updated_at < ?", 1.month.ago).each { |pod|
      if !pod.fleet.is_most_recent? && pod.machines.running.size == 0
        pod.cleanup_ami
      end
    }
  end
end
