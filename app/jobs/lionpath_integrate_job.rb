class LionpathIntegrateJob < ApplicationJob

  # When using rake task, file_exist must = true
  # This will use existing file 'app/parsing_files/courses_taught.csv' instead of uploaded file
  def perform(params, log_path, file_exist=false)
    error_logger = Logger.new("public/#{log_path}")
    error_logger.info "Courses Taught Integration to #{params[:target]} initiated at: #{DateTime.now}"
    if file_exist == false
      f_name = params[:courses_file].original_filename
      f_path = File.join('app', 'parsing_files', f_name)
      File.open(f_path, "wb") { |f| f.write(params[:courses_file].read) }
    else
      # Running bash script to grab lionpath files
      `#{Rails.root}/bin/courses-taught.sh`
      f_path = File.join('app', 'parsing_files', 'courses_taught.csv')
    end
    my_lionpath_populate = LionPathPopulateDB.new(LionPathParser.new(filepath = f_path))
    my_lionpath_populate.format_and_filter
    my_lionpath_populate.populate
    lionpath_integrate = IntegrateData.new(LionPathXMLBuilder.new, params[:target])
    errors = lionpath_integrate.integrate
    File.delete(f_path) if File.exist?(f_path)
    error_logger.info "Errors for Courses Taught Integration to #{params[:target]} at: #{DateTime.now}"
    error_logger.error errors
  end
end
