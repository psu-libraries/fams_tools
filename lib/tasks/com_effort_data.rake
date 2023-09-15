namespace :com_effort do
  desc 'Integrate COM Effort data.'

  task :integrate, [:target] => :environment do |_task, _args|
    Rails.application.eager_load!
    start = Time.now
    # Takes params hash -> params[:target] must be defined (:beta or :production)
    params = { target: :beta }
    puts params
    ComEffortIntegrateJob.perform_now(params, 'log/com_effort_errors.log', false)
    finish = Time.now
    puts(((finish - start) / 60).to_s + ' mins')
  end
end
