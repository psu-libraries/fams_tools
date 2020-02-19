class ApplicationJob < ActiveJob::Base
  class ConcurrentJobsError < StandardError; end
  include SuckerPunch::Counter

  before_perform :prevent_concurrent_jobs, :increment_busy, :clear_tmp_files, :delete_all_data
  after_perform :clear_busy, :clear_tmp_files, :delete_all_data

  discard_on(StandardError) do |job, error|
    raise error.class if error.class == ConcurrentJobsError

    clean_up
  end

  private

  def prevent_concurrent_jobs
    raise ConcurrentJobsError, 'An integration is currently running.' if Busy.new('integration').value != 0
  end

  def increment_busy
    Busy.new('integration').increment
  end

  def clean_up
    clear_busy
    clear_tmp_files
    delete_all_data
  end

  def clear_busy
    Busy.clear
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