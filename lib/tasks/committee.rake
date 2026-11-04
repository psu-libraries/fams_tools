namespace :committee do
  desc 'Import committee data from ETDA and integrate with Activity Insight'
  task :integrate, %i[target month_range] => :environment do |_task, args|
    target = args[:target].blank? ? :production : args[:target].to_sym
    month_range = args[:month_range].present? ? args[:month_range].to_i : 1
    params = { target:, month_range: }
    ActivityInsightCommitteeJob.perform_now(params, 'log/committee_errors.log')
  end
end
