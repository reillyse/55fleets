class LogEntriesController < ApplicationController
  before_action :authenticate_user!
  before_action :find_app

  def get_next_log
    last_log = params[:last_log].to_i

    @machine = @app.builder_machines.where(:id => params[:machine_id]).first
    logger.debug  "Machine is #{@machine.inspect}"

    if @machine.nil?
      @machine = @app.machines.find(params[:machine_id])
    else

    end

    @log_entries = LogEntry.where(:machine_id => @machine.id, :log_line.gt => last_log).limit(100).asc(:log_line).to_a

    respond_to do |format|
      format.js do
        if @log_entries.count > 0
          #          Rails.logger.debug @log_entries.inspect
          @last_log = @log_entries.map(&:log_line).max
          render :json => @log_entries.to_json
        else
          render :text => "", :status => :ok and return
        end
      end
    end
  end
end
