class CreateUsersIntegrateJob < ApplicationJob
  def integrate(params, _user_uploaded = true)
    CreateUserService.new(params['target']).create_user
  end

  private

  def name
    'Create Users Integration'
  end
end
