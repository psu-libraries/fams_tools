class AiIntegrationController < ApplicationController
  rescue_from StandardError, with: :error_redirect if Rails.env == 'production'

  skip_before_action :verify_authenticity_token, only: :render_integrator
  before_action :set_log_paths
  before_action :confirm_passcode, only: [:osp_integrate, :lionpath_integrate, :gpa_integrate, :pub_integrate, :ldap_integrate, :cv_pub_integrate, :cv_presentation_integrate]

  def osp_integrate
    start = Time.now
    OspIntegrateJob.perform_now(params, @osp_log_path)
    finish = Time.now
    time = (((finish - start)/60).to_i.to_s + ' minutes')
    flash[:notice] = "Integration completed in #{time}."
    redirect_to ai_integration_path
  end
  
  def lionpath_integrate
    start = Time.now
    LionpathIntegrateJob.perform_now(params, @courses_log_path)
    finish = Time.now
    time = (((finish - start)/60).to_i.to_s + ' minutes')
    flash[:notice] = "Integration completed in #{time}."
    redirect_to ai_integration_path
  end

  def gpa_integrate
    start = Time.now
    GpaIntegrateJob.perform_now(params, @gpas_log_path)
    finish = Time.now
    time = (((finish - start)/60).to_i.to_s + ' minutes')
    flash[:notice] = "Integration completed in #{time}."
    redirect_to ai_integration_path
  end

  def pub_integrate
    raise StandardError, "Must select a college." if params[:college].empty?
    start = Time.now
    PubIntegrateJob.perform_now(params, @publications_log_path)
    finish = Time.now
    time = (((finish - start)/60).to_i.to_s + ' minutes')
    flash[:notice] = "Integration completed in #{time}."
    redirect_to ai_integration_path
  end

  def ldap_integrate
    start = Time.now
    LdapIntegrateJob.perform_now(params, @ldap_log_path)
    finish = Time.now
    time = (((finish - start)/60).to_i.to_s + ' minutes')
    flash[:notice] = "Integration completed in #{time}."
    redirect_to ai_integration_path
  end

  def cv_pub_integrate
    start = Time.now
    CvPubIntegrateJob.perform_now(params, @cv_publications_log_path)
    finish = Time.now
    time = (((finish - start)/60).to_i.to_s + ' minutes')
    flash[:notice] = "Integration completed in #{time}."
    redirect_to ai_integration_path
  end

  def cv_presentation_integrate
    start = Time.now
    CvPresentationIntegrateJob.perform_now(params, @cv_presentations_log_path)
    finish = Time.now
    time = (((finish - start)/60).to_i.to_s + ' minutes')
    flash[:notice] = "Integration completed in #{time}."
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
