class ApplicationController < ActionController::Base
  include ControllerServices
  protect_from_forgery with: :exception
end
