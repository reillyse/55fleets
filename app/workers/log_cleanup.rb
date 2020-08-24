class LogCleanup
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform
    LogEntry.where(:created_at.lte => ENV['LOG_STORAGE_LIMIT'] || 1.month.ago)
      .delete_all
  end
end
