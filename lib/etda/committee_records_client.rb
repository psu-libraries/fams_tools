require 'httparty'

module Etda
  class CommitteeRecordsClient
    class CommitteeRecordsClientError < StandardError; end

    def initialize(url:, api_token:)
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

    # Tells us the error with committee records client with the error itself
    rescue StandardError => e
      raise CommitteeRecordsClientError, e.message
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
      raise CommitteeRecordsClientError, response.parsed_response['error'] || 'Unknown error' unless response.success?

      {
        success: true,
        data: response.parsed_response
      }
    end
  end
end
