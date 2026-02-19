require 'httparty'
module Etda
  class CommitteeRecordsClient
    def faculty_committees(access_id)
      response = HTTParty.post(
        "#{@base_url}/api/v1/committee_records/faculty_committees",
        headers: headers,
        body: body(access_id)
      )

      handle_response(response)
    rescue StandardError => e
      { success: false, error: e.message }
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
        'Authorization' => "Bearer #{@token}",
        'Content-Type' => 'application/json'
      }
    end

    def body(access_id)
      {
        access_id: access_id
      }.to_json
    end

    def handle_response(response)
      if response.success?
        {
          success: true,
          data: response.parsed_response
        }
      else
        {
          success: false,
          error: response.parsed_response['error'] || 'Unknown error',
          status: response.code
        }
      end
    end
  end
end
