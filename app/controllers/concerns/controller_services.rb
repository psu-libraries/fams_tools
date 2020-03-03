module ControllerServices
  def integrator_view(integration_type)
    case integration_type
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
end