require 'pub_data/pub_populate_db'
require 'pub_data/pub_xml_builder'
require 'osp_data/osp_parser'
require 'osp_data/osp_populate_db'
require 'osp_data/osp_xml_builder'
require 'lionpath_data/lionpath_parser'
require 'lionpath_data/lionpath_populate_db'
require 'lionpath_data/lionpath_xml_builder'
require 'ldap_data/import_ldap_data'
require 'ldap_data/ldap_xml_builder'
require 'activity_insight/ai_integrate_data'
require 'activity_insight/ai_manage_duplicates'

class AiIntegrationController < ApplicationController

  before_action :delete_all_data, :clear_tmp_files, :confirm_passcode, only: [:osp_integrate, :lionpath_integrate, :pub_integrate, :ldap_integrate]

  def osp_integrate
    start = Time.now
    f_name = params[:congrant_file].original_filename
    f_path = File.join('app', 'parsing_files', f_name)
    File.open(f_path, "wb") { |f| f.write(params[:congrant_file].read) }
    backup_name = params[:ai_backup_file].original_filename
    backup_path = File.join('app', 'parsing_files', backup_name)
    File.open(backup_path, "wb") { |f| f.write(params[:ai_backup_file].read) }
    my_populate = OspPopulateDB.new(OspParser.new(osp_path = f_path, backup_path = backup_path))
    my_populate.format_and_filter
    my_populate.populate
    my_remove_system_dups = RemoveSystemDups.new(filepath = backup_path, params[:target])
    my_remove_system_dups.call
    my_integrate = IntegrateData.new(OspXMLBuilder.new, params[:target])
    @errors = my_integrate.integrate
    finish = Time.now
    @time = (((finish - start)/60).to_i.to_s + ' minutes')
    File.delete(backup_path) if File.exist?(backup_path)
    File.delete(f_path) if File.exist?(f_path)
    flash[:notice] = "Integration completed in #{@time}."
    flash[:congrant_errors] = @errors
    redirect_to ai_integration_path
  end
  
  def lionpath_integrate
    start = Time.now
    f_name = params[:courses_file].original_filename
    f_path = File.join('app', 'parsing_files', f_name)
    File.open(f_path, "wb") { |f| f.write(params[:courses_file].read) }
    my_lionpath_populate = LionPathPopulateDB.new(LionPathParser.new(filepath = f_path))
    my_lionpath_populate.format_and_filter
    my_lionpath_populate.populate
    lionpath_integrate = IntegrateData.new(LionPathXMLBuilder.new, params[:target])
    @errors = lionpath_integrate.integrate
    finish = Time.now
    @time = (((finish - start)/60).to_i.to_s + ' minutes')
    File.delete(f_path) if File.exist?(f_path)
    flash[:notice] = "Integration completed in #{@time}."
    flash[:courses_errors] = @errors
    redirect_to ai_integration_path 
  end

  def pub_integrate
    start = Time.now
    import_pubs = GetPubData.new
    import_pubs.call(PubPopulateDB.new)
    my_integrate = IntegrateData.new(PubXMLBuilder.new, params[:target])
    @errors = my_integrate.integrate
    finish = Time.now
    @time = (((finish - start)/60).to_i.to_s + ' minutes')
    flash[:notice] = "Integration completed in #{@time}."
    flash[:pubs_errors] = @errors
    redirect_to ai_integration_path
  end

  def ldap_integrate
    start = Time.now
    import_ldap = ImportLdapData.new
    import_ldap.import_ldap_data
    ldap_integrate = IntegrateData.new(LdapXmlBuilder.new, params[:target])
    @errors = ldap_integrate.integrate
    finish = Time.now
    @time = (((finish - start)/60).to_i.to_s + ' minutes')
    flash[:notice] = "Integration completed in #{@time}."
    flash[:pubs_errors] = @errors
    redirect_to ai_integration_path
  end

  def cv_pub_integrate
    start = Time.now

    finish = Time.now
    @time = (((finish - start)/60).to_i.to_s + ' minutes')
    flash[:notice] = "Integration completed in #{@time}."
    redirect_to ai_integration_path
  end

  def index
  end

  private

  def confirm_passcode
    unless params[:passcode] == Rails.application.config_for(:integration_passcode)[:passcode]
      flash[:alert] = "Wrong Passcode"
      redirect_to ai_integration_path
    end
  end

  def clear_tmp_files
    Dir.foreach('app/parsing_files') do |f|
      fn = File.join('app/parsing_files', f)
      File.delete(fn) if File.exist?(fn) && f != '.' && f != '..'
    end
  end

  def delete_all_data
    ContractFacultyLink.delete_all
    Contract.delete_all
    Sponsor.delete_all
    Section.delete_all
    Course.delete_all
    PublicationFacultyLink.delete_all
    ExternalAuthor.delete_all
    Publication.delete_all
    PersonalContact.delete_all
  end

end
