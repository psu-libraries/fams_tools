namespace :courses_taught do

  desc "Integrate Courses Taught data."

  task integrate: :environment do
    start = Time.now
    # Takes params hash -> params[:target] and params[:courses_file]
    # Also needs path to log file from Rails.root
    params = { target: :beta, courses_file: "courses_taught.csv"}
    LionpathIntegrateJob.perform_now(params, 'log/courses_errors.log')
    finish = Time.now
    puts(((finish - start)/60).to_s + ' mins')
  end
end
