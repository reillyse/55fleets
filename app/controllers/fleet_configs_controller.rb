class FleetConfigsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_app


  def index
    @fleet_configs = @app.fleet_configs.order("created_at desc")
  end

  def new
    @fleet_config = @app.fleet_configs.new
    10.times {@fleet_config.pod_configs.build}

  end

  def create
    params.permit!

    @fleet_config = @app.fleet_configs.new params[:fleet_config]
    dud_pcs = @fleet_config.pod_configs.select {|pc| pc.name.blank?}
    @fleet_config.pod_configs = @fleet_config.pod_configs - dud_pcs

    @fleet_config.save!
    @fleet_config.pod_configs.each {|pc|
      pc.repo_id = @app.repo.id
      pc.save!
    }


    redirect_to [@app,@fleet_config]
  end

  def show
    @fleet_config = @app.fleet_configs.where(:id => params[:id]).first
  end


  def launch
    @fleet_config = @app.fleet_configs.find params[:id]
    @fleet = Fleet.create! :app => @app, :fleet_config => @fleet_config
    FleetLauncher.perform_now(@fleet.id,@fleet_config.id)
    redirect_to app_fleets_path(@app), :alert => "Launch Starting"  and return
  end

  def launch_from_fleet
    @fleet = @app.fleets.find params[:fleet_id]
    @new_fleet = @fleet.dup
    @new_fleet.pods = @fleet.pods.map(&:dup)
    @new_fleet.rolling_deploy_started_at  = nil
    @new_fleet.rolling_deploy_completed_at  = nil
    @new_fleet.save!
    @new_fleet.pods.each do |pod|
      PodInit.perform_later pod.id
    end
    redirect_to app_fleets_path(@app)
  end
end
