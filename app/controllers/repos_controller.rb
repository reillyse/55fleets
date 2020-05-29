class ReposController  < ApplicationController
  before_action :authenticate_user!
  skip_before_action :find_app

  def index
    @repos = current_user.repos
  end

  def new
    if current_user.provider == "bitbucket"

      @repos = current_user.bb.repos.list
    elsif current_user.provider == "github"
      @repos = current_user.github.repos # this should work for the current logged in user"reillyse"
    else
      raise "no git provider"
    end

    @app_id = current_user.apps.find(params[:app_id]).id
  end

  def show
    @repo = current_user.repos.find params[:id]

  end

  def create
    name = params[:name]
    app =  current_user.apps.find params[:app_id]
    repo = current_user.repos.create! :repo_name => name, :type => (current_user.provider + "_repo").camelcase
    repo.add_key
    repo.add_url

    repo.save!
    app.repo = repo
    app.save!

    redirect_to repo.app, :notice => "repo connected #{name}"
  end
end
