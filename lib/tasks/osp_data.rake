namespace :contract_grants do

  desc "Integrate Contract Grant data."

  task integrate: :environment do
    Rails.application.eager_load!
    start = Time.now
    # Takes params hash -> params[:target] must be defined (:beta or :production)
    params = { target: :beta }
    OspIntegrateJob.perform_now(params, 'log/osp_errors.log', false)
    finish = Time.now
    puts(((finish - start)/60).to_s + ' mins')
  end
end
