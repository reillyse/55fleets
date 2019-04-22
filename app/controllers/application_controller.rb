class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :authenticate_user!

  before_filter :find_app
  
  def keep_alive
    render :text => :ok, :status => :ok
  end
  private
  
  def find_app
    Rails.logger.debug "looking for an app called #{params[:app_id]}"
    @app = current_user.apps.friendly.find(params[:app_id])
  end

  rescue_from NotAllowed do |exception|
    render text: "This user does not have permission to access this resource", status: 401
    puts exception.message
    Rollbar.report_exception exception
  end
end
