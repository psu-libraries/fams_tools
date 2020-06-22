class ApplicationJob < ActiveJob::Base
  class ConcurrentJobsError < StandardError; end

  before_perform :prevent_concurrent_jobs, :integration_start, :clear_tmp_files, :delete_all_data
  after_perform :integration_stop, :clear_tmp_files, :delete_all_data

  discard_on(StandardError) do |job, error|
    raise error.class if error.class == ConcurrentJobsError

    job.clean_up
    raise error
  end

  def clean_up
    integration_stop
    clear_tmp_files
    delete_all_data
  end

  def perform(params, log_path, _file_exist = false)
    error_logger = Logger.new("public/#{log_path}")
    error_logger.info "#{name} to #{params[:target]} initiated at: #{DateTime.now}"
    errors = integrate(params, _file_exist)
    error_logger.info "Errors for #{name} to #{params[:target]} at: #{DateTime.now}"
    errors.each do |error|
      error_logger.error "____________________________________________________"
      error_logger.error "Error: #{error[:response]}" if error[:response]
      error_logger.error "Affected Faculty: #{error[:affected_faculty]}" if error[:affected_faculty]
      error_logger.error "Affected OSPs: #{error[:affected_osps]}" if error[:affected_osps]
    end
  end

  private

  def name
    ## Define in subclass as a string that describes this integration
  end

  def prevent_concurrent_jobs
    raise ConcurrentJobsError, 'An integration is currently running.' if Integration.running?
  end

  def integration_start
    Integration.start
  end

  def integration_stop
    Integration.stop
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
end