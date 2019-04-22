class EnvConfigsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_app

  def new
    @env_config = @app.env_configs.new
  end

  def create
    params.permit!
    @env_config = @app.env_configs.find_or_create_by name: params[:env_config][:name]
    @env_config.value = params[:env_config][:value]
    render :new and return unless @env_config.save
    redirect_to app_env_configs_path(@app)    
  end

  def index
    @configs = @app.env_configs
  end

  def destroy
    @env_config = @app.env_configs.find params[:id]
    @env_config.delete
    redirect_to app_env_configs_path(@app)
  end

  def edit
    @env_config = @app.env_configs.find params[:id]    
  end

  def update
    @env_config = @app.env_configs.find params[:id]
    @env_config.value = params[:env_config][:value]
    @env_config.name = params[:env_config][:name]
    render :edit  and return unless @env_config.save

    redirect_to app_env_configs_path(@app)
  end
  
end
