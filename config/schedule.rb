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

# This custom job will exit if it is not Monday.  Used for contract/grant integration
job_type :monday_rake,
         'test $(date +%u) -eq 1 && cd :path && :environment_variable=:environment bundle exec rake :task --silent :output'

every '0 7 1 * *', roles: [:app] do
  rake 'cron:download_backup'
end

every '0 0 1 2,5,7,8,10,12 *', roles: [:app] do
  rake 'courses_taught:integrate'
end

every '0 1 8-14,22-28 * *', roles: [:app] do
  # This job should run on the second and fourth Monday of every month
  monday_rake 'contract_grants:integrate'
end

every '0 22 * * 0', roles: [:app] do
  rake 'activity_insight:get_user_data'
end

# every '0 0 * 4,8,12 2', roles: [:app] do
#   # first Tuesday of April, August, and December
#   rake 'com_effort:integrate'
# end

# every '0 0 * 4,8,12 2', roles: [:app] do
#   # first Tuesday of April, August, and December
#   rake 'com_quality:integrate'
# end
