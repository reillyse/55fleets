class AppTeardown < ActiveJob::Base
  queue_as :low

  def perform(app_id)
    #need to have no machines first
    app = App.find app_id
    app.load_balancers.each(&:kill)

    app.vpcs.each(&:kill)
    app.delete
  end
end
