module ControllerServices
  def integrator_view(integration_type)
    case integration_type
    when :congrant
      render partial: 'congrant'
    when :courses_taught
      render partial: 'courses_taught'
    when :yearly
      render partial: 'yearly'
    when :publications
      @colleges = Faculty.distinct.pluck(:college).reject(&:blank?).sort
      @colleges << 'All Colleges'
      render partial: 'publications'
    when :personal_contact
      render partial: 'personal_contact'
    when :delete_records
      @resources = ActivityInsight::DeleteRecords::RESOURCES.sort
      render partial: 'delete_records'
    when :com_effort
      render partial: 'com_effort'
    when :com_quality
      render partial: 'com_quality'
    else
      render partial: 'blank'
    end
  end
end
