# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

every '0 0 1 * *', roles: [:app] do
  rake 'cron:download_backup'
end

every '0 0 1 2,7,10 *', roles: [:app] do
  rake 'courses_taught:integrate'
end

every '0 1 8-14 * *', roles: [:app] do
  # This job should run on the second Monday of every month
  return unless Date.today.strftime('%u').to_i == 1

  rake 'contract_grants:integrate'
end

every '0 22 * * 0', roles: [:app] do
  rake 'activity_insight:get_user_data'
end
