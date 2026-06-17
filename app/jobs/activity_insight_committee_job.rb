class ActivityInsightCommitteeJob < ApplicationJob
  def integrate(target, since: nil)
    window_since, window_until = since ? [since, since.next_month] : default_window
    CommitteeData::EtdaImporter.new.import_all(since: window_since, until_date: window_until)

    builder   = CommitteeData::CommitteeXmlBuilder.new
    xml_enum  = builder.xmls_enumerator

    integrator = ActivityInsight::IntegrateData.new(xml_enum, target, :post)
    integrator.integrate
  end

  private

  def default_window
    [Date.current.prev_month.change(day: 10), Date.current.change(day: 10)]
  end

  def name
    'Committee Integration'
  end
end
