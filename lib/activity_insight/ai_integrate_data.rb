class IntegrateData
  attr_accessor :auth, :url, :batched_xmls, :responses

  def initialize(xml_builder_obj)
    @auth = {:username => Rails.application.config_for(:activity_insight)[:username],
            :password => Rails.application.config_for(:activity_insight)[:password]}
    @url = 'https://beta.digitalmeasures.com/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-University'
    @batched_xmls = xml_builder_obj.batched_xmls
    @responses = []
  end

  def integrate
    counter = 0
    batched_xmls.each do |xml|
      puts xml
      response = HTTParty.post url, :body => xml, :headers => {'Content-type' => 'text/xml'}, :basic_auth => auth, :timeout => 180
      if response.include? 'Error'
        counter += 1
      end
      responses << response
    end
    #puts counter
  end

end
