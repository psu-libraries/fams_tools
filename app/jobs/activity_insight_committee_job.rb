class ActivityInsightCommitteeJob < ApplicationJob
  def integrate(target, month_range: 1)
    since_date  = month_range.months.ago.to_date.change(day: 10)
    until_date  = Date.current.change(day: 10)
    CommitteeData::EtdaImporter.new.import_all(since: since_date, until_date:)

    builder    = CommitteeData::CommitteeXmlBuilder.new
    xml_enum   = builder.xmls_enumerator

    integrator = ActivityInsight::IntegrateData.new(xml_enum, target, :post)
    integrator.integrate
  end

  private

  def name
    'Committee Integration'
  end
end
