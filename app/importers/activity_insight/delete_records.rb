class DeleteRecords
  class InvalidResource < StandardError; end

  RESOURCES = %w[CONGRANT SCHTEACH INTELLCONT PCI GRADE_DIST_GPA STUDENT_RATING].freeze

  def initialize(resource, target)
    raise InvalidResource unless RESOURCES.include? resource.to_s

    @resource = resource
    @target = target
  end

  def delete
    xmls_array = []
    CSV.foreach(csv_path, headers: true).to_a.in_groups_of(1000) do |batch|
      builder = Nokogiri::XML::Builder.new do |xml|
      xml.Data {
        xml.send(resource.to_s) {
          batch.each do |row|
            if row.blank?
              next
            else
              xml.item( 'id' => row['ID'] )
            end
          end
          }
        }
      end
      xmls_array << builder.to_xml
    end
    request(xmls_array)
  end

  private

  def csv_path
    "#{Rails.root}/app/parsing_files/delete.csv"
  end

  def request(xmls_array)
    integrator = IntegrateData.new(xmls_array, target, :delete)
    integrator.integrate
  end

  attr_reader :target, :resource
end
