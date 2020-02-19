class ApplicationJob < ActiveJob::Base
  class ConcurrentJobs < StandardError; end
  include SuckerPunch::Job
  include SuckerPunch::Counter

  before_perform :prevent_concurrent_jobs, :increment_busy
  after_perform :clear_busy

  private

  def prevent_concurrent_jobs
    raise ConcurrentJobs, 'An integration is currently running.' if Busy.new('integration').value != 0
  end

  def increment_busy
    Busy.new('integration').increment
  end

  def clear_busy
    Busy.clear
  end
end