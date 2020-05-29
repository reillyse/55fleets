class HomeController < ApplicationController
  before_action :authenticate_user!, :except => [:welcome, :setup]
  before_action :find_app, :except => [:welcome,:setup]
  
  def welcome
    
  end

  def setup
  end 
end
