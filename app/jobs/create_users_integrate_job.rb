class CreateUsersIntegrateJob < ApplicationJob
  def integrate(params, _user_uploaded = true)
    errors = CreateUserService.new(params['target']).create_user
    errors
  end

  private

  def name
    'Create Users Integration'
  end
end
