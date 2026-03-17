class ActivityInsightCommitteeJob < ApplicationJob
  def integrate(target)
    CommitteeData::EtdaImporter.new.import_all

    builder   = CommitteeData::CommitteeXmlBuilder.new
    xml_enum  = builder.xmls_enumerator

    integrator = ActivityInsight::IntegrateData.new(xml_enum, target, :post)
    integrator.integrate
  end

  private

  def name
    'Committee Integration'
  end
end
