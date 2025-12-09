class ActivityInsightCommitteeJob < ApplicationJob

  def integrate(target)
    builder = CommitteeData::CommitteeXmlBuilder.new

    enumerator = builder.xmls_enumerator
    errors = integrate_committee_data(enumerator, target)

    errors
  end

  private
  def integrate_committee_data(xml_enum, target)
    committee_integrator_obj(xml_enum, target).integrate
  end

  def committee_integrator_obj(xml_enum, target)
    # ActivityInsight::gitIntegrateData.new(<xml_enum>, target, :post)
    ActivityInsight::IntegrateData.new(xml_enum, target, :post)
  end

  def name
    "Committee Membership Integration"
  end
end
