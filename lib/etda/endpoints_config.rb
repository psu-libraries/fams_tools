module Etda
  class EndpointsConfig
    class UnknownEndpointError < StandardError; end

    ENDPOINT_NAMES = [:etda, :honors, :millennium_scholars, :sset].freeze

    def self.all_endpoints
      {
        etda: endpoint(:etda),
        honors: endpoint(:honors),
        millennium_scholars: endpoint(:millennium_scholars),
        sset: endpoint(:sset)
      }
    end

    def self.endpoint(name)
      raise UnknownEndpointError, "Unknown endpoint: #{name}" unless ENDPOINT_NAMES.include?(name)

      case name
      when :etda
        {
          url: ENV.fetch('ETDA_API_URL', 'http://localhost:3000'),
          api_token: ENV.fetch('ETDA_API_TOKEN', 'abc123')
        }
      when :honors
        {
          url: ENV.fetch('HONORS_API_URL', 'http://localhost:3001'),
          api_token: ENV.fetch('HONORS_API_TOKEN', 'honors_token')
        }
      when :millennium_scholars
        {
          url: ENV.fetch('MILLENNIUM_SCHOLARS_API_URL', 'http://localhost:3002'),
          api_token: ENV.fetch('MILLENNIUM_SCHOLARS_API_TOKEN', 'ms_token')
        }
      when :sset
        {
          url: ENV.fetch('SSET_API_URL', 'http://localhost:3003'),
          api_token: ENV.fetch('SSET_API_TOKEN', 'sset_token')
        }
      end
    end

    def self.endpoint_names
      ENDPOINT_NAMES
    end
  end
end
