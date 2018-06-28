class GetPureData
  attr_accessor :pure_ids, :pub_xmls

  def initialize
    @pure_ids = PureId.pluck(:pure_id)
    @pub_xmls = []
  end

  def get_pub_xmls
    headers = {"Accept" => "application/xml", "api-key" => "#{Rails.application.config_for(:pure)[:api_key]}"}
    pure_ids.each do |id|
      url = "https://pennstate.pure.elsevier.com/ws/api/511/persons/#{id}/research-outputs"
      response = HTTParty.get url, :headers => headers, :timeout => 100
      pub_xmls << response
    end
  end

end
