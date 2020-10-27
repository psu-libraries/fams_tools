class IntegrateData
  attr_accessor :auth, :xml_enumerator, :target, :action

  def initialize(xml_enumerator, target, action)
    @auth = {:username => Rails.application.config_for(:activity_insight)["webservices"][:username],
            :password => Rails.application.config_for(:activity_insight)["webservices"][:password]}
    @xml_enumerator = xml_enumerator
    @target = target.to_sym
    @action = action.to_sym
  end

  def integrate
    errors = []
    Rails.logger.info url
    xml_enumerator.each do |xml|
      Rails.logger.info xml
      response = HTTParty.post url, :body => xml, :headers => {'Content-type' => 'text/xml'}, :basic_auth => auth, :timeout => 180
      if response.to_s.include? 'Error'
        osp_keys = Nokogiri::XML(xml).xpath("//OSPKEY").collect{|r| r.children.to_s}
        access_ids = Nokogiri::XML(xml).xpath("//Record").collect{|r| r.attr('username')}
        itr_errors = {}
        itr_errors[:response] = response.parsed_response
        itr_errors[:affected_faculty] = access_ids unless access_ids.empty?
        itr_errors[:affected_osps] = osp_keys unless osp_keys.empty?
        errors << itr_errors
      end
      Rails.logger.info response
    end
    errors
  end

  private

  def url
    case target
    when :beta
      if action == :delete
        'https://betawebservices.digitalmeasures.com/login/service/v4/SchemaData:delete/INDIVIDUAL-ACTIVITIES-University'
      else
        'https://betawebservices.digitalmeasures.com/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-University'
      end
    when :production
      if action == :delete
        'https://webservices.digitalmeasures.com/login/service/v4/SchemaData:delete/INDIVIDUAL-ACTIVITIES-University'
      else
        'https://webservices.digitalmeasures.com/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-University'
      end
    end
  end
end
