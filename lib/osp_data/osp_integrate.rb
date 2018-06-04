require 'osp_data/osp_xml_builder'

class OspIntegrate
  attr_accessor :auth, :url, :osp_batches

  def initialize
    @auth = {:username => Rails.application.config_for(:activity_insight)[:username],
            :password => Rails.application.config_for(:activity_insight)[:password]}
    @url = 'https://beta.digitalmeasures.com/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-University'
    @osp_batches = OspXMLBuilder.new.batched_osp_xml
  end

  #Make sure to run integration only after population
  def integrate
    counter = 0
    osp_batches.each do |xml|
      puts xml
      response = HTTParty.post url, :body => xml, :headers => {'Content-type' => 'text/xml'}, :basic_auth => auth, :timeout => 180
      puts response
      if response.include? 'Error'
        counter += 1
      end
    end
    puts counter
  end

end
