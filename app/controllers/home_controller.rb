class HomeController < ApplicationController
  before_filter :authenticate_user!, :except => [:welcome, :setup]
  before_filter :find_app, :except => [:welcome,:setup]
  
  def welcome
    
  end

  def setup
  end 
end
