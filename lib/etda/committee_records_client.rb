require './lib/etda/committee_records_client'
require 'httparty'
module Etda
  class CommitteeRecordsClient
    class CommitteeRecordsClientError < StandardError; end

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

    private

    def base_url
      @base_url ||= ENV.fetch('ETDA_API_URL', 'http://localhost:3000')
    end

    def api_token
      @api_token ||= ENV.fetch('ETDA_API_TOKEN', 'abc123')
    end

    def headers
      {
        'X-API-KEY' => api_token,
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
