class CvPubIntegrateJob < ApplicationJob
  queue_as :default

  def perform(params, log_path)
    error_logger = Logger.new("public/#{log_path}")
    f_name = params[:cv_pub_file].original_filename
    f_path = File.join('app', 'parsing_files', f_name)
    File.open(f_path, "wb") { |f| f.write(params[:cv_pub_file].read) }
    import_cv_pubs = ImportCVPubs.new(f_path)
    import_cv_pubs.import_cv_pubs_data
    my_integrate = IntegrateData.new(PubXMLBuilder.new, params[:target])
    errors = my_integrate.integrate
    File.delete(f_path) if File.exist?(f_path)
    error_logger.info "Errors for CV Publications Integration to #{params[:target]} on: #{DateTime.now}"
    error_logger.error errors
  end
end
