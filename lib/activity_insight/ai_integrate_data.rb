class IntegrateData
  attr_accessor :auth, :url, :batched_xmls, :responses

  def initialize(xml_builder_obj)
    @auth = {:username => Rails.application.config_for(:activity_insight)[:username],
            :password => Rails.application.config_for(:activity_insight)[:password]}
    @url = 'https://beta.digitalmeasures.com/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-University'
    @batched_xmls = xml_builder_obj.batched_xmls
  end

  def integrate
    errors = []
    counter = 0
    batched_xmls.each do |xml|
      #puts xml
      response = HTTParty.post url, :body => xml, :headers => {'Content-type' => 'text/xml'}, :basic_auth => auth, :timeout => 180
      if response.include? 'Error'
        counter += 1
        errors << response.parsed_response
      end
    end
    return errors
    #puts counter
  end

end
