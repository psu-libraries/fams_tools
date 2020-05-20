class LionpathIntegrateJob < ApplicationJob
  # When using rake task, file_exist must = true
  # This will use existing file 'app/parsing_files/courses_taught.csv'
  # instead of uploaded file
  def perform(params, log_path, file_exist = false)
    error_logger = Logger.new("public/#{log_path}")
    error_logger.info info_message(params[:target])
    f_path = create_tmp_file(params, file_exist)
    populate_course_data(f_path)
    errors = integrate_course_data(params[:target])
    File.delete(f_path) if File.exist?(f_path)
    error_logger.info error_message(params[:target])
    error_logger.error errors
  end

  private

  def create_tmp_file(params, file_exist)
    if file_exist == false
      f_name = params[:courses_file].original_filename
      f_path = File.join('app', 'parsing_files', f_name)
      File.open(f_path, 'wb') { |f| f.write(params[:courses_file].read) }
      f_path
    else
      # Running bash script to grab lionpath files
      `#{Rails.root}/bin/courses-taught.sh`
      File.join('app', 'parsing_files', 'courses_taught.csv')
    end
  end

  def populate_course_data(f_path)
    lionpath = lionpath_populate_obj(f_path)
    lionpath.format_and_filter
    lionpath.populate
  end

  def lionpath_populate_obj(f_path)
    LionPathPopulateDB.new(LionPathParser.new(f_path))
  end

  def integrate_course_data(target)
    lionpath_integrate_obj(target).integrate
  end

  def lionpath_integrate_obj(target)
    IntegrateData.new(LionPathXMLBuilder.new, target)
  end

  def error_message(target)
    "Errors for Courses Taught Integration to #{target} at: #{DateTime.now}"
  end

  def info_message(target)
    "Courses Taught Integration to #{target} initiated at: #{DateTime.now}"
  end
end
