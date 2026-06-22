namespace :committee do
  desc 'Import committee data from ETDA and integrate with Activity Insight'
  task :integrate, %i[target month_range] => :environment do |_task, args|
    target      = args[:target].blank? ? :production : args[:target].to_sym
    month_range = args[:month_range].present? ? args[:month_range].to_i : 1
    ActivityInsightCommitteeJob.new.integrate(target, month_range: month_range)
  end
end
