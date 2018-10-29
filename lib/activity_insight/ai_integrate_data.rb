class IntegrateData
  attr_accessor :auth, :batched_xmls, :target

  def initialize(xml_builder_obj, target)
    @auth = {:username => Rails.application.config_for(:activity_insight)[:username],
            :password => Rails.application.config_for(:activity_insight)[:password]}
    @batched_xmls = xml_builder_obj.batched_xmls
    @target = target.to_sym
  end

  def integrate
    errors = []
    counter = 0
    puts url(target)
    batched_xmls.each do |xml|
      puts xml
      response = HTTParty.post url(target), :body => xml, :headers => {'Content-type' => 'text/xml'}, :basic_auth => auth, :timeout => 180
      if response.to_s.include? 'Error'
        counter += 1
        errors << response.parsed_response
      end
      puts response
    end
    return errors
    #puts counter
  end

  private

  def url(target)
    case target
    when :beta
      return 'https://beta.digitalmeasures.com/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-University'
    when :alpha
      return 'https://alpha.digitalmeasures.com/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-University'
    when :production
      puts "*Runs Production Integration*"
      #return 'https://www.digitalmeasures.com/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-University'
    end
  end

end
