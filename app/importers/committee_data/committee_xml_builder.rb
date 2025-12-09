require 'nokogiri'

class CommitteeData::CommitteeXmlBuilder
  def xmls_enumerator
    Enumerator.new do |yielder|
      Faculty.includes(:committees)
             .joins(:committees)
             .distinct
             .find_in_batches(batch_size: 20) do |batch|
        yielder << build_xml(batch)
      end
    end
  end
end
