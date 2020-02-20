class IntegrateData
  attr_accessor :auth, :xml_builder_enum, :target

  def initialize(xml_builder_obj, target)
    @auth = {:username => Rails.application.config_for(:activity_insight)["webservices"][:username],
            :password => Rails.application.config_for(:activity_insight)["webservices"][:password]}
    @xml_builder_enum = xml_builder_obj.xmls_enumerator
    @target = target.to_sym
  end

  def integrate
    errors = []
    counter = 0
    Rails.logger.info url(target)
    xml_builder_enum.each do |xml|
      Rails.logger.info xml
      response = HTTParty.post url(target), :body => xml, :headers => {'Content-type' => 'text/xml'}, :basic_auth => auth, :timeout => 180
      if response.to_s.include? 'Error'
        osp_keys = Nokogiri::XML(xml).xpath("//OSPKEY").collect{|r| r.children.to_s}
        itr_errors = []
        counter += 1
        itr_errors << response.parsed_response
        itr_errors << Nokogiri::XML(xml).xpath("//Record").collect{|r| r.attr('username')}
        itr_errors << osp_keys unless osp_keys.empty?
        itr_errors.flatten!
        errors << itr_errors.join(', ')
      end
      Rails.logger.info response
    end
    return errors
    #puts counter
  end

  private

  def url(target)
    case target
    when :beta
      return 'https://betawebservices.digitalmeasures.com/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-University'
    when :production
      return 'https://webservices.digitalmeasures.com/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-University'
    end
  end

end
