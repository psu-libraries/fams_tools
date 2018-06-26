class GetPureIDs
  attr_accessor :faculties, :pure_xmls, :pure_ids

  def intialize
    @faculties = Faculty.all
    @pure_xmls = []
    @pure_ids = {}
  end

  def call
    get_xml
    xml_to_hash(pure_xmls)
  end

  private

  def get_xml
    increments = [1,2,3,4,5,6]
    headers = {'Accept' => 'application/xml', 'api-key' => "#{Rails.application.config_for(:pure)[:api_key]}"}
    increments.each do |increment|
      url = "https://pennstate.pure.elsevier.com/ws/api/511/persons?pageSize=1000&page=#{increment}" 
      response = HTTParty.get url, :headers => headers, :timeout => 100
      @pure_xmls << response
    end
  end

  def xml_to_hash(xml_arr)
    xml_arr.each do |xml|
      noko_obj = Nokogiri::XML.parse(xml.to_s)
      noko_obj.xpath('//result//person').each do |person|
        puts person.attr('externalId')
        puts person.attr('pureId')
      end
    end
  end

end
