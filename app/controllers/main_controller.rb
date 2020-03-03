require 'activity_insight/ai_get_user_data'

class MainController < ApplicationController
  def update_ai_user_data
    File.delete(psu_users_path) if File.exist?(psu_users_path)
    File.open(psu_users_path, "wb") { |f| f.write(params[:psu_users_file].read) }
    my_get_user_data = GetUserData.new(psu_users_path)
    my_get_user_data.call
    File.delete(psu_users_path) if File.exist?(psu_users_path)
    flash[:notice] = "Update successful!"
    redirect_to root_path
  end

  def index
  end

  private

  def psu_users_path
    psu_users_name = params[:psu_users_file].original_filename
    File.join('app', 'parsing_files', psu_users_name)
  end
end
