

task :upload_users => :environment do
CreateUserService.new.create_user
end