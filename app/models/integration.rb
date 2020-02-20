class Integration < ApplicationRecord

  def self.is_running?
    find_by(process_type: 'integration').is_active
  end

  def self.start
    find_by(process_type: 'integration').update_attribute(:is_active, true)
  end

  def self.stop
    find_by(process_type: 'integration').update_attribute(:is_active, false)
  end

  def self.seed
    Integration.create(process_type: 'integration', is_active: 'false')
  end
end