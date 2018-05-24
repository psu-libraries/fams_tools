class ImportUserids
  attr_accessor :xml_arr, :userid_hash

  def initialize
    @xml_arr = get_user_xmls
    @userid_hash = xml_to_userid_hash(xml_arr)
  end

  def call
    link_to_faculties(userid_hash)
  end

  private 

  def get_user_xmls
    xml_arr = []
    auth = {:username => Rails.application.config_for(:activity_insight)[:username],
            :password => Rails.application.config_for(:activity_insight)[:password]}
    url = 'https://beta.digitalmeasures.com/login/service/v4/User/INDIVIDUAL-ACTIVITIES-University'
    response = HTTParty.get url, :basic_auth => auth, :timeout => 180
    #puts response
    xml = Nokogiri::XML.parse(response.to_s)
    xml_arr << xml
    xml_arr
  end

  def xml_to_userid_hash(arr)
    userid_hash = {}
    arr.each do |xml|
      xml.xpath('//Users//User').each do |user|
        userid_hash[user.attr('username')] = user.attr('dmu:userId')
      end
    end
    userid_hash
  end

  def link_to_faculties(userid_hash)
    puts userid_hash
  end

end
