class AppsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_app, :only => [:show,:update,:edit]
  caches_action :show, cache_path: Proc.new { @app.updated_at.to_s + request.format.to_s }, expires_in: 1.hour

  def find_app
    #overwriting find_app
    @app = current_user.apps.friendly.find(params[:id])
  end

  def show

    respond_to do |format|
      format.json { render :json =>  @app.for_react and return}
      format.html {}
    end

  end

  def create
    @app = current_user.apps.create! :name => params[:app][:name]
    redirect_to new_repo_path(:app_id => @app.id), :notice => "App created"
  end

  def update
    @app.name = @app.name
    @app.save!
    redirect_to @app
  end

  def edit
    raise "not implemented"
  end

  def index
    @apps = current_user.apps
  end

  def new
    @app = current_user.apps.new
  end


end
