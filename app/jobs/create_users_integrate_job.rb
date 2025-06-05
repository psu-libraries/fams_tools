class CreateUsersIntegrateJob < ApplicationJob
  def integrate(params, _user_uploaded = true)
    f_name = 'upload.csv'
    f_path = File.join('app', 'parsing_files', f_name)
    File.binwrite(f_path, params[:create_users_file].read)
    errors = CreateUserService.new.create_user
    File.delete(f_path) if File.exist?(f_path)
    errors
  end

  private

  def name
    'Create Users Integration'
  end
end
