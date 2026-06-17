namespace :committee do
  desc 'Import committee data from ETDA and integrate with Activity Insight'
  task :integrate, %i[target since] => :environment do |_task, args|
    target = args[:target].blank? ? :production : args[:target].to_sym
    since  = args[:since].present? ? Date.parse(args[:since]) : nil
    ActivityInsightCommitteeJob.new.integrate(target, since: since)
  end
end
