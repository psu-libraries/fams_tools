class CommitteeRoleNormalizer
  PRIORITY_REGEX = [
    ['Co-Chairperson', %r{(co[-\s]?chair|co[-\s]?chairperson|committee chair/co-chair)}i],
    ['Chairperson', /(chairperson|chair of committee|committee chair|chair.)/i],
    ['Co-Advisor', /(co[-\s]?dissertation\s*advis(or|er)|co[-\s]?advisor)/i],
    ['Advisor', /(dissertation\s*advis(?:o?r|er)|advis(?:o?r|er))/i],
    ['Supervisor', /supervisor/i],
    ['Mentor', /mentor/i],
    ['Second Reader', /second\s+reader/i],
    ['Reader', /reader/i],
    ['Member', /(member|rep|represent|representative|substitute)/i]
    
  ].freeze

  def self.normalize(raw_name)
    text = raw_name.to_s.strip
    return 'Other' if text.empty?

    PRIORITY_REGEX.each do |label, regex|
      return label if text.match?(regex)
    end

    'Other'
  end
end
