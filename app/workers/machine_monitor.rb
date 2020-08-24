class MachineMonitor
  include Sidekiq::Worker
  def perform
    Machine.running.each { |m| MachineStateUpdaterWorker.perform_async m.id }
  end
end
