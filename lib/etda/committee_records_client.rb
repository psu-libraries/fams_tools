require './lib/etda/endpoints_config'
require 'httparty'

module Etda
  class CommitteeRecordsClient
    class CommitteeRecordsClientError < StandardError; end

    def initialize(endpoint: :etda)
      @endpoint = endpoint
    end

    def faculty_committees(access_id)
      response = HTTParty.post(
        "#{base_url}/api/v1/committee_records/faculty_committees",
        headers: headers,
        body: body(access_id)
      )

      handle_response(response)

    # Tells us the error with committe records client with the error itself
    rescue StandardError => e
      raise CommitteeRecordsClientError, e.message
    end

    def faculty_committees_from_all_endpoints(access_id)
      results = {}

      EndpointsConfig.endpoint_names.each do |endpoint_name|
        results[endpoint_name] = fetch_from_endpoint(endpoint_name, access_id)
      end

      results
    end

    private

    def fetch_from_endpoint(endpoint_name, access_id)
      config = EndpointsConfig.endpoint(endpoint_name)

      response = HTTParty.post(
        "#{config[:url]}/api/v1/committee_records/faculty_committees",
        headers: headers_for_token(config[:api_token]),
        body: body(access_id)
      )

      result = handle_response(response)
      result.merge(endpoint: endpoint_name)
    rescue CommitteeRecordsClientError => e
      {
        success: false,
        error: e.message,
        endpoint: endpoint_name
      }
    end

    def base_url
      @base_url ||= EndpointsConfig.endpoint(@endpoint)[:url]
    end

    def api_token
      @api_token ||= EndpointsConfig.endpoint(@endpoint)[:api_token]
    end

    def headers
      headers_for_token(api_token)
    end

    def headers_for_token(token)
      {
        'X-API-KEY' => token,
        'Content-Type' => 'application/json'
      }
    end

    def body(access_id)
      {
        access_id: access_id
      }.to_json
    end

    def handle_response(response)
      raise CommitteeRecordsClientError, response.parsed_response['error'] || 'Unknown error' unless response.success?

      {
        success: true,
        data: response.parsed_response
      }
    end
  end
end
