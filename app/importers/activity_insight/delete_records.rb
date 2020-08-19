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
    auth = {:username => Rails.application.config_for(:activity_insight)["webservices"][:username],
            :password => Rails.application.config_for(:activity_insight)["webservices"][:password]}
    if target == :beta
      url = 'https://betawebservices.digitalmeasures.com/login/service/v4/SchemaData:delete/INDIVIDUAL-ACTIVITIES-University'
    elsif target == :prod
      url = 'https://webservices.digitalmeasures.com/login/service/v4/SchemaData:delete/INDIVIDUAL-ACTIVITIES-University'
    else
      return
    end
    response = HTTParty.post url, :basic_auth => auth, :body => data, :headers => {'Content-type' => 'text/xml'}, :timeout => 320
    puts response
  end

  attr_reader :target, :resource
end
