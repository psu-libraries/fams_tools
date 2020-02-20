class CvPresentationIntegrateJob < ApplicationJob

  def perform(params, log_path)
    error_logger = Logger.new("public/#{log_path}")
    f_name = params[:cv_presentation_file].original_filename
    f_path = File.join('app', 'parsing_files', f_name)
    File.open(f_path, "wb") { |f| f.write(params[:cv_presentation_file].read) }
    import_cv_presentations = ImportCVPresentations.new(f_path)
    import_cv_presentations.import_cv_presentations_data
    my_integrate = IntegrateData.new(PresentationXMLBuilder.new, params[:target])
    errors = my_integrate.integrate
    File.delete(f_path) if File.exist?(f_path)
    error_logger.info "Errors for CV Presentations Integration to #{params[:target]} on: #{DateTime.now}"
    error_logger.error errors
  end
end
