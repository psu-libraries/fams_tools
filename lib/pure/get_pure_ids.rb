class GetPureIDs
  attr_accessor :ai_access_ids, :pure_xmls, :pure_ids, :ai_pure_hash

  def initialize
    @ai_access_ids = Faculty.pluck(:access_id)
    @pure_xmls = []
    @pure_ids = {}
    @ai_pure_hash = {}
  end

  def call
    get_xml
    xml_to_hash(pure_xmls)
    match_ai_users(pure_ids)
    populate_db(ai_pure_hash)
  end

  private

  def get_xml
    increments = [1,2,3,4,5,6]
    headers = {'Accept' => 'application/xml', 'api-key' => "#{Rails.application.config_for(:pure)[:api_key]}"}
    increments.each do |increment|
      url = "https://pennstate.pure.elsevier.com/ws/api/511/persons?pageSize=1000&page=#{increment}" 
      response = HTTParty.get url, :headers => headers, :timeout => 100
      pure_xmls << response
    end
  end

  def xml_to_hash(pure_xmls)
    pure_xmls.each do |xml|
      noko_obj = Nokogiri::XML.parse(xml.to_s)
      noko_obj.xpath('//result//person').each do |person|
        pure_ids[person.attr('externalId')] = person.attr('pureId')
      end
    end
  end

  def match_ai_users(pure_ids)
    pure_ids.each do |k,v|
      if ai_access_ids.include? k
        ai_pure_hash[k] = v
      end 
    end
  end

  def populate_db(ai_pure_hash)
    ai_pure_hash.each do |k,v|
      faculty = Faculty.find_by(:access_id => k.downcase)

      PureId.create(pure_id:    v,
                    faculty: faculty)
    end
  end
end
