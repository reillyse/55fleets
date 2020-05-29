class PodsController < ApplicationController
  before_action :find_app

  def scale
    @pod = @app.pods.find params[:pod_id]
    if params[:pod_scale][:machine_type] == "on_demand"
      logger.debug "We are scaling on demand"
      @pod.scale_permanent(params[:pod_scale][:new_amount].to_i)
    else
      logger.debug "we are scaling spots"
      @pod.spot_amount = params[:pod_scale][:new_amount].to_i
      @pod.save!
      SpotFleetScaleWorker.perform_async @pod.id,params[:pod_scale][:new_amount].to_i
    end

    ScalePodWorker.perform_later(@pod.id)


    respond_to do |format|
      format.json { render :json => {:message => "Scaled" }, :status => :ok}.to_json
    end
  end
end
