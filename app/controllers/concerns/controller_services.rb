module ControllerServices
  def integrator_view(integration_type)
    case integration_type
    when :congrant
      render partial: 'congrant'
    when :courses_taught
      render partial: 'courses_taught'
    when :gpa
      render partial: 'gpa'
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
    else
      render partial: 'blank'
    end
  end
end
