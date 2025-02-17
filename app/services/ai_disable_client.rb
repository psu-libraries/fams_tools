# frozen_string_literal: true

require 'httparty'

class AiDisableClient
  class ClientError < StandardError; end

  include HTTParty
  base_uri ENV.fetch('FAMS_WEBSERVICES_BASE_URI', 'https://betawebservices.digitalmeasures.com/login/service/v4')

  def initialize(
    username = ENV.fetch('FAMS_WEBSERVICES_USERNAME', nil),
    password = ENV.fetch('FAMS_WEBSERVICES_PASSWORD', nil)
  )
    @options = {
      basic_auth: {
        username:,
        password:
      },
      headers: {
        'Accept' => 'text/xml',
        'Content-Type' => 'text/xml'
      },
      timeout: 180
    }
  end

  def user(uid)
    self.class.get("/User/USERNAME:#{uid}", @options)
  end

  def enable_user(uid, value)
    self.class.put("/User/USERNAME:#{uid}", @options.merge({ body: "<User enabled=\"#{value}\"/>" }))
  end
end
