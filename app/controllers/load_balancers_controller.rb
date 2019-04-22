class LoadBalancersController < ApplicationController
  before_filter :find_app

  def add_certificate
    cert = @app.certs.find params[:cert_id]
    lb = @app.load_balancers.find params[:load_balancer_id]
    lb.certs = [cert]
    lb.save!
    lb.update_certs
    redirect_to app_load_balancers_path(@app)
  end

  def list_certificates
    @certs = @app.certs
    @lb = @app.load_balancers.find params[:load_balancer_id]
  end

  def index
    @load_balancers = @app.load_balancers
  end
end
