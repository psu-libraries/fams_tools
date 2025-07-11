class AiIntegrationController < ApplicationController
  rescue_from StandardError, with: :error_redirect if Rails.env.production?

  INTEGRATIONS = %i[osp_integrate lionpath_integrate
                    yearly_integrate pub_integrate ldap_integrate
                    delete_records com_effort_integrate com_quality_integrate create_users_integrate].freeze

  skip_before_action :verify_authenticity_token, only: :render_integrator
  before_action :set_log_paths
  before_action :confirm_passcode, only: INTEGRATIONS

  def osp_integrate
    start = Time.now
    OspIntegrateJob.perform_now(params, @osp_log_path)
    finished(start)
  end

  def lionpath_integrate
    start = Time.now
    LionpathIntegrateJob.perform_now(params, @courses_log_path)
    finished(start)
  end

  def yearly_integrate
    start = Time.now
    YearlyIntegrateJob.perform_now(params, @yearlies_log_path)
    finished(start)
  end

  def pub_integrate
    raise StandardError, 'Must select a college or enter an access ID.' if params[:college].empty? && params[:access_id].empty?

    start = Time.now
    PubIntegrateJob.perform_now(params, @publications_log_path)
    finished(start)
  end

  def ldap_integrate
    start = Time.now
    LdapIntegrateJob.perform_now(params, @ldap_log_path)
    finished(start)
  end

  def delete_records
    start = Time.now
    DeleteRecordsJob.perform_now(params, @delete_records_path)
    finished(start)
  rescue ActivityInsight::DeleteRecords::InvalidResource => e
    flash[:alert] = e.message
    redirect_to ai_integration_path
  end

  def com_effort_integrate
    start = Time.now
    ComEffortIntegrateJob.perform_now(params, @com_effort_log_path)
    finished(start)
  end

  def com_quality_integrate
    start = Time.now
    ComQualityIntegrateJob.perform_now(params, @com_quality_log_path)
    finished(start)
  end

  def create_users_integrate
    start = Time.now
    CreateUsersIntegrateJob.perform_now(params, @create_users_log_path)
    finished(start)
  end

  def index
    @integration_types =
      { 'Contract/Grant Integration' => :congrant,
        'Courses Taught Integration' => :courses_taught,
        'RMD Publications Integration' => :publications,
        'Personal & Contact Integration' => :personal_contact,
        'Yearly Integration' => :yearly,
        'Delete Records' => :delete_records,
        'COM Effort Integration' => :com_effort,
        'COM Quality Integration' => :com_quality,
        'Create Users Integration' => :create_users }
  end

  def render_integrator
    integrator_view params[:integration_type].to_sym
  end

  private

  def set_log_paths
    @osp_log_path = Pathname.new('log/osp_errors.log')
    @courses_log_path = Pathname.new('log/courses_errors.log')
    @yearlies_log_path = Pathname.new('log/yearly_errors.log')
    @publications_log_path = Pathname.new('log/publications_errors.log')
    @ldap_log_path = Pathname.new('log/ldap_errors.log')
    @delete_records_path = Pathname.new('log/delete_records_errors.log')
    @com_effort_log_path = Pathname.new('log/com_effort_errors.log')
    @com_quality_log_path = Pathname.new('log/com_quality_errors.log')
    @create_users_log_path = Pathname.new('log/create_users_errors.log')
  end

  def confirm_passcode
    return if params[:passcode] == passcode

    flash[:alert] = 'Wrong Passcode'
    redirect_to ai_integration_path
  end

  def passcode
    Rails.application.config_for(:integration_passcode)[:passcode]
  end

  def finished(start_time)
    finish = Time.now
    time = (((finish - start_time) / 60).to_i.to_s + ' minutes')
    flash[:notice] = "Integration completed in #{time}."
    redirect_to ai_integration_path
  end

  def error_redirect(exception)
    Rails.logger.error exception.to_s
    flash[:error] = exception.to_s
    redirect_to ai_integration_path
  end
end
