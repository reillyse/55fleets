class CertsController < ApplicationController
  before_filter :find_app
  
  def new
    @cert = @app.certs.new :port => "443"
  end

  def create
    begin
      params.permit!
      @cert = @app.certs.create! params[:cert]
      redirect_to [@app,@cert]

    rescue => e
      puts e.message
      Rails.logger.debug e.message
      redirect_to app_certs_path(@app), :flash => { :error => e.message }
    end
  end

  def index
    @certs = @app.certs
  end

  def destroy
    @cert = @app.certs.find params[:id]
    @cert.delete
    redirect_to app_certs_path(@app)
  end

  def show
    @cert = @app.certs.find params[:id]
  end

  
end
