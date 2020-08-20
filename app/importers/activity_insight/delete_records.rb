class DeleteRecords
  class InvalidResource < StandardError; end

  RESOURCES = %w[CONGRANT SCHTEACH INTELLCONT PCI GRADE_DIST_GPA STUDENT_RATING].freeze

  def initialize(resource, target)
    raise InvalidResource unless RESOURCES.include? resource.to_s

    @resource = resource
    @target = target
  end

  def delete
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.Data {
        xml.send(resource.to_s) {
          CSV.foreach(csv_path, headers: true) do |row|
            if row.empty?
              next
            else
              xml.item( 'id' => row['ID'] )
            end
          end
        }
      }
    end
    request(builder.to_xml)
  end

  private

  def csv_path
    "#{Rails.root}/app/parsing_files/delete.csv"
  end

  def request(data)
    integrator = IntegrateData.new([data], target, :delete)
    integrator.integrate
  end

  attr_reader :target, :resource
end
