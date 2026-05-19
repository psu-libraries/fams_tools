require 'httparty'

module Etda
  class CommitteeRecordsClient
    class CommitteeRecordsClientError < StandardError; end

    def initialize(url:, api_token:)
      raise ArgumentError, 'url is required' if url.blank?
      raise ArgumentError, 'api_token is required' if api_token.blank?

      @url = url
      @api_token = api_token
    end

    def faculty_committees(access_id)
      response = HTTParty.post(
        "#{@url}/api/v1/committee_records/faculty_committees",
        headers: headers,
        body: body(access_id)
      )

      handle_response(response)
    rescue HTTParty::Error, Timeout::Error => e
      raise CommitteeRecordsClientError, "API request failed: #{e.message}"
    end

    private

    def headers
      {
        'X-API-KEY' => @api_token,
        'Content-Type' => 'application/json'
      }
    end

    def body(access_id)
      {
        access_id: access_id
      }.to_json
    end

    def handle_response(response)
      unless response.success?
        error_msg = response.parsed_response['error'] || 'Unknown error'
        raise CommitteeRecordsClientError, "HTTP #{response.code}: #{error_msg}"
      end

      {
        success: true,
        data: response.parsed_response
      }
    end
  end
end
