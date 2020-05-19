require 'autoinc'

class LogEntry

  include Mongoid::Document
  include Mongoid::Autoinc
  include Mongoid::Timestamps





  field :stdout, type: String
  field :stderr, type: String
  field :exit_signal, type: String
  field :machine_id, type: Integer
  field :pod_id, type: Integer
  field :stage, type: String
  field :log_line, type: Integer

  increments :log_line, scope: :machine_id, seed: 0

  field :exit_code, type: String

  index({ machine_id: 1, log_line: 1})


  def self.write_log params
    begin
      LogEntry.create! params
    rescue => e
      Rails.logger.debug e.message
      logger.error e.message
    end
  end
end
