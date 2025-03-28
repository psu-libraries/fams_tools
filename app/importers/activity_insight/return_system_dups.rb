# Finds CONGRANT duplicates directly in the system
class ActivityInsight::ReturnSystemDups
  attr_accessor :username_arr, :responses, :xml_arr, :congrant_hash

  def initialize(usernames = [])
    @username_arr = usernames
    @responses = get_congrant_xmls
  end

  def call
    put_duplicates(xml_to_hash(noko_xml(responses)))
  end

  private

  def get_congrant_xmls
    responses = []
    auth = { username: Rails.application.config_for(:activity_insight)['webservices'][:username],
             password: Rails.application.config_for(:activity_insight)['webservices'][:password] }
    username_arr.each do |username|
      url = 'https://betawebservices.digitalmeasures.com/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-University/USERNAME:' + username + '/CONGRANT'
      # url = 'https://webservices.digitalmeasures.com/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-University/USERNAME:' + username + '/CONGRANT'
      responses << (HTTParty.get url, basic_auth: auth)
    end
    responses
  end

  def noko_xml(responses)
    responses.map do |response|
      Nokogiri::XML.parse(response.to_s)
    end
  end

  def xml_to_hash(xml_arr)
    congrant_hash = {}
    xml_arr.each do |xml|
      xml.xpath('//Data:Record', 'Data' => 'http://www.digitalmeasures.com/schema/data').each do |record|
        congrant_hash[record.attr('username')] = []
        record.xpath('xmlns:CONGRANT').each do |congrant|
          unless congrant.xpath('xmlns:OSPKEY').text == ''
            congrant_hash[record.attr('username')] << [congrant.xpath('xmlns:TITLE').text,
                                                       congrant.xpath('xmlns:OSPKEY').text, congrant.attr('id')]
          end
        end
      end
    end
    congrant_hash
  end

  def put_duplicates(congrant_hash)
    congrant_hash.each do |k, v|
      ospkeys = v.pluck(1)
      puts k
      puts ospkeys.select { |e| ospkeys.count(e) > 1 }.uniq
    end
  end
end
