class WebhooksController < ApplicationController
  protect_from_forgery :except => :push
  skip_before_filter :find_app
  skip_before_filter :authenticate_user!
  
  def push
    Rails.logger.info params
    puts params.inspect

    repo = Repo.find_by_secret_key params[:secret_key]
    WebhookPush.create_from_webhook(params.merge(:repo_id => repo.id))
    fc = repo.app.fleets.last.fleet_config
    
    @fleet = Fleet.create! :app => fc.app, :fleet_config => fc 
    FleetLauncher.perform_later(@fleet.id,fc.id)
    render :text => "push received", :status => :ok and return
  end
end
