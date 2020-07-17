namespace :courses_taught do

  desc "Integrate Courses Taught data."

  task integrate: :environment do
    Rails.application.eager_load!
    start = Time.now
    # Takes params hash -> params[:target] must be defined (:beta or :production)
    params = { target: :production }
    LionpathIntegrateJob.perform_now(params, 'log/courses_errors.log', true)
    finish = Time.now
    puts(((finish - start)/60).to_s + ' mins')
  end
end
