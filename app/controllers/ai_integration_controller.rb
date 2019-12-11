require 'pub_data/pub_populate_db'
require 'pub_data/pub_xml_builder'
require 'pub_data/import_cv_pubs'
require 'presentation_data/import_cv_presentations'
require 'presentation_data/presentation_xml_builder'
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
require 'gpa_data/import_gpa_data'
require 'gpa_data/gpa_xml_builder'

class AiIntegrationController < ApplicationController
  rescue_from StandardError, with: :error_redirect if Rails.env == 'production'

  skip_before_action :verify_authenticity_token, only: :render_integrator
  before_action :set_log_paths
  before_action :delete_all_data, :clear_tmp_files, :confirm_passcode, only: [:osp_integrate, :lionpath_integrate, :gpa_integrate, :pub_integrate, :ldap_integrate, :cv_pub_integrate, :cv_presentation_integrate]

  def osp_integrate
    start = Time.now
    error_logger = Logger.new("#{@osp_log_path}")
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
    error_logger.info "Errors for Contract/Grant Integration to #{params[:target]} on: #{DateTime.now}"
    error_logger.error @errors
    redirect_to ai_integration_path
  end
  
  def lionpath_integrate
    start = Time.now
    error_logger = Logger.new("#{@courses_log_path}")
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
    error_logger.info "Errors for Courses Taught Integration to #{params[:target]} on: #{DateTime.now}"
    error_logger.error @errors
    redirect_to ai_integration_path 
  end

  def gpa_integrate
    start = Time.now
    error_logger = Logger.new("#{@gpas_log_path}")
    f_name = params[:gpa_file].original_filename
    f_path = File.join('app', 'parsing_files', f_name)
    File.open(f_path, "wb") { |f| f.write(params[:gpa_file].read) }
    gpa_importer = ImportGpaData.new(f_path)
    gpa_importer.import
    gpa_xml_builder = GpaXmlBuilder.new
    gpa_integration = IntegrateData.new(gpa_xml_builder, params[:target])
    @errors = gpa_integration.integrate
    finish = Time.now
    @time = (((finish - start)/60).to_i.to_s + ' minutes')
    File.delete(f_path) if File.exist?(f_path)
    flash[:notice] = "Integration completed in #{@time}."
    error_logger.info "Errors for GPA Integration to #{params[:target]} on: #{DateTime.now}"
    error_logger.error @errors
    redirect_to ai_integration_path
  end

  def pub_integrate
    raise StandardError, "Must select a college." if params[:college].empty?
    start = Time.now
    import_pubs = GetPubData.new(params[:college])
    error_logger = Logger.new("#{@publications_log_path}")
    import_pubs.call(PubPopulateDB.new)
    my_integrate = IntegrateData.new(PubXMLBuilder.new, params[:target])
    @errors = my_integrate.integrate
    finish = Time.now
    @time = (((finish - start)/60).to_i.to_s + ' minutes')
    flash[:notice] = "Integration completed in #{@time}."
    error_logger.info "Errors for Publications Integration to #{params[:target]} on: #{DateTime.now}"
    error_logger.error @errors
    redirect_to ai_integration_path
  end

  def ldap_integrate
    start = Time.now
    error_logger = Logger.new("#{@ldap_log_path}")
    import_ldap = ImportLdapData.new
    import_ldap.import_ldap_data
    ldap_integrate = IntegrateData.new(LdapXmlBuilder.new, params[:target])
    @errors = ldap_integrate.integrate
    finish = Time.now
    @time = (((finish - start)/60).to_i.to_s + ' minutes')
    flash[:notice] = "Integration completed in #{@time}."
    error_logger.info "Errors for Personal & Contact Info Integration to #{params[:target]} on: #{DateTime.now}"
    error_logger.error @errors
    redirect_to ai_integration_path
  end

  def cv_pub_integrate
    start = Time.now
    error_logger = Logger.new("#{@cv_publications_log_path}")
    f_name = params[:cv_pub_file].original_filename
    f_path = File.join('app', 'parsing_files', f_name)
    File.open(f_path, "wb") { |f| f.write(params[:cv_pub_file].read) }
    import_cv_pubs = ImportCVPubs.new(f_path)
    import_cv_pubs.import_cv_pubs_data
    my_integrate = IntegrateData.new(PubXMLBuilder.new, params[:target])
    @errors = my_integrate.integrate
    File.delete(f_path) if File.exist?(f_path)
    finish = Time.now
    @time = (((finish - start)/60).to_i.to_s + ' minutes')
    flash[:notice] = "Integration completed in #{@time}."
    error_logger.info "Errors for CV Publications Integration to #{params[:target]} on: #{DateTime.now}"
    error_logger.error @errors
    redirect_to ai_integration_path
  end

  def cv_presentation_integrate
    start = Time.now
    error_logger = Logger.new("#{@cv_presentations_log_path}")
    f_name = params[:cv_presentation_file].original_filename
    f_path = File.join('app', 'parsing_files', f_name)
    File.open(f_path, "wb") { |f| f.write(params[:cv_presentation_file].read) }
    import_cv_presentations = ImportCVPresentations.new(f_path)
    import_cv_presentations.import_cv_presentations_data
    my_integrate = IntegrateData.new(PresentationXMLBuilder.new, params[:target])
    @errors = my_integrate.integrate
    File.delete(f_path) if File.exist?(f_path)
    finish = Time.now
    @time = (((finish - start)/60).to_i.to_s + ' minutes')
    flash[:notice] = "Integration completed in #{@time}."
    error_logger.info "Errors for CV Presentations Integration to #{params[:target]} on: #{DateTime.now}"
    error_logger.error @errors
    redirect_to ai_integration_path
  end

  def index
    @integration_types = { "Contract/Grant Integration" => :congrant,
                           "Courses Taught Integration" => :courses_taught,
                           "GPA Integration" => :gpa,
                           "RMD Publications Integration" => :publications,
                           "Personal & Contact Integration" => :personal_contact,
                           "CV Publications Integration" => :cv_publications,
                           "CV Presentations Integration" => :cv_presentations }
  end

  def render_integrator
    case params[:integration_type].to_sym
    when :congrant
      render partial: 'congrant.html.erb'
    when :courses_taught
      render partial: 'courses_taught.html.erb'
    when :gpa
      render partial: 'gpa.html.erb'
    when :publications
      @colleges = Faculty.distinct.pluck(:college).reject(&:blank?).sort
      @colleges << 'All Colleges'
      render partial: 'publications.html.erb'
    when :personal_contact
      render partial: 'personal_contact.html.erb'
    when :cv_publications
      render partial: 'cv_publications.html.erb'
    when :cv_presentations
      render partial: 'cv_presentations.html.erb'
    else
      render partial: 'blank.html.erb'
    end
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
    Presentation.delete_all
    PresentationContributor.delete_all
    Gpa.delete_all
  end

  def error_redirect(exception)
    Rails.logger.error exception.to_s
    flash[:error] = "#{exception}"
    redirect_to ai_integration_path
  end

  def set_log_paths
    @osp_log_path = Pathname.new("log/osp_errors.log")
    @courses_log_path = Pathname.new("log/courses_errors.log")
    @gpas_log_path = Pathname.new("log/gpa_errors.log")
    @publications_log_path = Pathname.new("log/publications_errors.log")
    @ldap_log_path = Pathname.new("log/ldap_errors.log")
    @cv_publications_log_path = Pathname.new("log/cv_publications_errors.log")
    @cv_presentations_log_path = Pathname.new("log/cv_presentations_errors.log")
  end
end
