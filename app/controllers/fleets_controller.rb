class FleetsController < ApplicationController

  before_filter :find_app, :except => :fleet_direct
  def show
    @fleet = @app.fleets.find params[:id]

    respond_to do |format|
      format.html { }
    end
  end

  def index
    @fleets = @app.fleets.order("created_at desc")
  end

  def fleet_direct
    fleet = current_user.fleets.where("fleets.id" => params[:id]).first

    respond_to do |format|
      format.json {
        render :status => :ok,:json => fleet.for_react and return
      }
    end
  end

end
