class OspIntegrateJob < ApplicationJob

  def integrate(params, _user_uploaded = true)
    if _user_uploaded == true
      f_path = create_dmresults_file(params)
      backup_path = create_backup_file(params)
    else
      # Running bash script to grab dmresults.csv and CONGRANT.csv files
      `#{Rails.root}/bin/contract-grants.sh #{backups_username} #{backups_password}`
      f_path = File.join('app', 'parsing_files', 'contract_grants.csv')
      backup_path = File.join('app', 'parsing_files', 'CONGRANT.csv')
    end
    populate_db(f_path, backup_path)
    remove_dups(backup_path, params)
    errors = integrator(params)
    delete_files(f_path, backup_path)
    errors
  end

  private

  def create_dmresults_file(params)
    f_name = params[:congrant_file].original_filename
    f_path = File.join('app', 'parsing_files', f_name)
    File.open(f_path, "wb") { |f| f.write(params[:congrant_file].read) }
    f_path
  end

  def create_backup_file(params)
    backup_name = params[:ai_backup_file].original_filename
    backup_path = File.join('app', 'parsing_files', backup_name)
    File.open(backup_path, "wb") { |f| f.write(params[:ai_backup_file].read) }
    backup_path
  end

  def populate_db(f_path, backup_path)
    my_populate = OspImporter.new(f_path, backup_path)
    my_populate.format_and_populate
  end

  def remove_dups(backup_path, params)
    my_remove_system_dups = RemoveSystemDups.new(backup_path, params[:target])
    my_remove_system_dups.call
  end

  def integrator(params)
    my_integrate = IntegrateData.new(OspXMLBuilder.new.xmls_enumerator, params[:target], :post)
    my_integrate.integrate
  end

  def delete_files(f_path, backup_path)
    File.delete(backup_path) if File.exist?(backup_path)
    File.delete(f_path) if File.exist?(f_path)
  end

  def backups_username
    Rails.application.config_for(:activity_insight)["backups_service"][:username]
  end

  def backups_password
    Rails.application.config_for(:activity_insight)["backups_service"][:password]
  end

  def name
    'Contract/Grant Integration'
  end
end
