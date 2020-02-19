class LionpathIntegrateJob < ApplicationJob

  def perform(params, log_path)
    error_logger = Logger.new("public/#{log_path}")
    f_name = params[:courses_file].original_filename
    f_path = File.join('app', 'parsing_files', f_name)
    File.open(f_path, "wb") { |f| f.write(params[:courses_file].read) }
    my_lionpath_populate = LionPathPopulateDB.new(LionPathParser.new(filepath = f_path))
    my_lionpath_populate.format_and_filter
    my_lionpath_populate.populate
    lionpath_integrate = IntegrateData.new(LionPathXMLBuilder.new, params[:target])
    errors = lionpath_integrate.integrate
    File.delete(f_path) if File.exist?(f_path)
    error_logger.info "Errors for Courses Taught Integration to #{params[:target]} on: #{DateTime.now}"
    error_logger.error errors
  end
end
