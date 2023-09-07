namespace :contract_grants do
  desc 'Integrate Contract Grant data.'

  task :integrate, [:target] => :environment do |_task, args|
    Rails.application.eager_load!
    start = Time.now
    # Takes params hash -> params[:target] must be defined (:beta or :production)
    params = { target: (args[:target].blank? ? :production : args[:target].to_sym) }
    puts params
    OspIntegrateJob.perform_now(params, 'log/osp_errors.log', false)
    finish = Time.now
    puts(((finish - start) / 60).to_s + ' mins')
  end
end
