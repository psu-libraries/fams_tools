class GpaIntegrateJob < ApplicationJob

  def perform(params, log_path)
    error_logger = Logger.new("public/#{log_path}")
    f_name = params[:gpa_file].original_filename
    f_path = File.join('app', 'parsing_files', f_name)
    File.open(f_path, "wb") { |f| f.write(params[:gpa_file].read) }
    gpa_importer = ImportGpaData.new(f_path)
    gpa_importer.import
    gpa_xml_builder = GpaXmlBuilder.new
    gpa_integration = IntegrateData.new(gpa_xml_builder, params[:target])
    errors = gpa_integration.integrate
    File.delete(f_path) if File.exist?(f_path)
    error_logger.info "Errors for GPA Integration to #{params[:target]} on: #{DateTime.now}"
    error_logger.error errors
  end
end
