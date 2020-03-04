require 'activity_insight/ai_get_user_data'

class MainController < ApplicationController
  def update_ai_user_data
    set_up_file
    user_data_update
    File.delete(psu_users_path) if File.exist?(psu_users_path)
    flash[:notice] = 'Update successful!'
    redirect_to root_path
  end

  def index; end

  private

  def psu_users_path
    psu_users_name = params[:psu_users_file].original_filename
    File.join('app', 'parsing_files', psu_users_name)
  end

  def set_up_file
    File.delete(psu_users_path) if File.exist?(psu_users_path)
    File.open(psu_users_path, 'wb') do |f|
      f.write(params[:psu_users_file].read)
    end
  end

  def user_data_update
    user_data_obj = GetUserData.new(psu_users_path)
    user_data_obj.call
  end
end
