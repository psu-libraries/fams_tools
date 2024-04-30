class Integration < ApplicationRecord
  PROCESS_TYPE = 'integration'.freeze

  def self.running?
    find_by(process_type: PROCESS_TYPE).is_active
  end

  def self.start
    find_by(process_type: PROCESS_TYPE).update_attribute(:is_active, true)
  end

  def self.stop
    find_by(process_type: PROCESS_TYPE).update_attribute(:is_active, false)
  end

  def self.seed
    Integration.create(process_type: PROCESS_TYPE, is_active: 'false') unless Integration.count > 0
  end
end
