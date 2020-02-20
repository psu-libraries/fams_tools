class OspIntegrateJob < ApplicationJob

  def perform(params, log_path)
    error_logger = Logger.new("public/#{log_path}")
    f_name = params[:congrant_file].original_filename
    f_path = File.join('app', 'parsing_files', f_name)
    File.open(f_path, "wb") { |f| f.write(params[:congrant_file].read) }
    backup_name = params[:ai_backup_file].original_filename
    backup_path = File.join('app', 'parsing_files', backup_name)
    File.open(backup_path, "wb") { |f| f.write(params[:ai_backup_file].read) }
    my_populate = OspImporter.new(osp_path = f_path, backup_path = backup_path)
    my_populate.format_and_populate
    my_remove_system_dups = RemoveSystemDups.new(filepath = backup_path, params[:target])
    my_remove_system_dups.call
    my_integrate = IntegrateData.new(OspXMLBuilder.new, params[:target])
    errors = my_integrate.integrate
    File.delete(backup_path) if File.exist?(backup_path)
    File.delete(f_path) if File.exist?(f_path)
    error_logger.info "Errors for Contract/Grant Integration to #{params[:target]} on: #{DateTime.now}"
    error_logger.error errors
  end
end
