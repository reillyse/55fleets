class Recycler
  include Sidekiq::Worker

  def perform(machine_id)
    m = Machine.find(machine_id)
    return unless m.running?
    m.recycle_as_new
  end
end
