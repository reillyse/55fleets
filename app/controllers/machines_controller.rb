class MachinesController < ApplicationController
  before_action :find_app , :only => :turn_on_logging

  def turn_on_logging
    @machine = @app.machines.find params[:machine_id]
    return false if @machine.is_a? BuilderMachine
    if @machine.running? && (@machine.logging_until.nil? || @machine.logging_until  < Time.now)
      LogWorker.perform_async(@machine.id)
    else
      Rails.logger.debug "Not running logger for #{@machine.id}"
    end
    respond_to do |format|
      format.html { redirect_to app_fleet_path(@app,@machine.fleet) and return }
      format.js { render :plain => "ok", :status => :ok}
      format.json { render :plain => "ok", :status => :ok}

    end

  end

  def show

    @machine = Machine.find params[:id]
    raise NotAllowed unless current_user.apps.map(&:machines).flatten.compact.include? @machine

    respond_to do |format|

      format.json { render :status => :ok,:json => @machine.as_json(:include => :subnet) and return }
    end
  end
end
