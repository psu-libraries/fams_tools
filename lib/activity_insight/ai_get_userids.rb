#This class id depricated.  Userids are pulled from the psu-users.xls file now.
private
class ImportUserids
  attr_accessor :response

  def initialize
    @response = get_user_xmls
  end

  def call
    link_to_faculties(xml_to_userid_hash(noko_xml(response)))
  end

  private 

  def get_user_xmls
    auth = {:username => Rails.application.config_for(:activity_insight)[:username],
            :password => Rails.application.config_for(:activity_insight)[:password]}
    url = 'https://beta.digitalmeasures.com/login/service/v4/User/INDIVIDUAL-ACTIVITIES-University'
    return HTTParty.get url, :basic_auth => auth, :timeout => 180
  end

  def noko_xml(response)
    return Nokogiri::XML.parse(response.to_s)
  end

  def xml_to_userid_hash(noko_xml)
    userid_hash = {}
    noko_xml.xpath('//Users//User').each do |user|
      userid_hash[user.attr('username').downcase] = user.attr('dmu:userId')
    end
    return userid_hash
  end

  def link_to_faculties(userid_hash)
    userid_hash.each do |k,v|
      faculty = Faculty.find_by(access_id: k)

      UserNum.create(faculty:   faculty,
                     id_number: v)
    end
  end

end
