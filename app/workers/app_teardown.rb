class AppTeardown < ActiveJob::Base

  queue_as :low

  def perform app_id
    #need to have no machines first
    app = App.find app_id
    app.load_balancers.each { |lb|
      lb.kill
    }

    app.vpcs.each { |v|

      v.kill}
    app.delete
  end
end
