namespace :com_quality do
  desc 'Integrate COM Quality data.'

  task :integrate, [:target] => :environment do |_task, args|
    Rails.application.eager_load!
    start = Time.now
    # Takes params hash -> params[:target] must be defined (:beta or :production)
    params = { target: (args[:target].blank? ? :production : args[:target].to_sym) }
    puts params
    ComQualityIntegrateJob.perform_now(params, 'log/com_quality_errors.log', false)
    finish = Time.now
    puts(((finish - start) / 60).to_s + ' mins')
  end
end
