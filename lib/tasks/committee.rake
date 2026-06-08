namespace :committee do
  desc 'Import committee data from ETDA and integrate with Activity Insight'
  task :integrate, [:target] => :environment do |_task, args|
    target = args[:target].blank? ? :production : args[:target].to_sym
    ActivityInsightCommitteeJob.new.integrate(target)
  end
end
