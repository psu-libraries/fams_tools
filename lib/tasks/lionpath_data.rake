namespace :courses_taught do

  desc "Integrate Courses Taught data."

  task integrate: :environment do
    start = Time.now
    # Takes params hash -> params[:target] must be defined (:beta or :prod)
    params = { target: :beta }
    LionpathIntegrateJob.perform_now(params, 'log/courses_errors.log', true)
    finish = Time.now
    puts(((finish - start)/60).to_s + ' mins')
  end
end
