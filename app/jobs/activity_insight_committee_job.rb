class ActivityInsightCommitteeJob < ApplicationJob
  def integrate(params, _user_uploaded: true)
    target = params[:target]

    builder   = CommitteeData::CommitteeXmlBuilder.new
    xml_enum  = builder.xmls_enumerator

    integrator = ActivityInsight::IntegrateData.new(xml_enum, target, :post)
    integrator.integrate
  end

  private

  def name
    'Committee Membership Integration'
  end
end
