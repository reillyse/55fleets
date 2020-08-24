class HomeController < ApplicationController
  before_action :authenticate_user!, except: %i[welcome setup]
  before_action :find_app, except: %i[welcome setup]

  def welcome; end

  def setup; end
end
