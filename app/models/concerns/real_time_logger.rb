module RealTimeLogger
  extend ActiveSupport::Concern
  included {}

  def add_log(stdout = nil, stderror = nil, pod = nil)
    pod = self.pod if pod == nil
    LogEntry.create! stdout: stdout, machine_id: self.id, pod_id: pod.id
  rescue => e
    logger.error e.message
  end
end
