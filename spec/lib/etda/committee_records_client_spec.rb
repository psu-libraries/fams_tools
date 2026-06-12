require 'rails_helper'
require_relative '../../../lib/etda/committee_records_client'

RSpec.describe Etda::CommitteeRecordsClient do
  let(:url) { 'https://etda.example.com' }
  let(:api_token) { 'test_token_123' }
  let(:client) { Etda::CommitteeRecordsClient.new(url: url, api_token: api_token) }

  describe '#initialize' do
    context 'when url is missing' do
      it 'raises ArgumentError' do
        expect do
          Etda::CommitteeRecordsClient.new(url: nil, api_token: 'token')
        end.to raise_error(ArgumentError, 'url is required')
      end
    end

    context 'when api_token is missing' do
      it 'raises ArgumentError' do
        expect do
          Etda::CommitteeRecordsClient.new(url: 'https://example.com', api_token: nil)
        end.to raise_error(ArgumentError, 'api_token is required')
      end
    end
  end

  describe '#faculty_committees' do
    context 'when the API returns committees' do
      it 'expects success with data' do
        fake_response = instance_double(HTTParty::Response,
                                        success?: true,
                                        parsed_response: [{ id: 1, name: 'Millennium Scholar' }])

        allow(HTTParty).to receive(:post).and_return(fake_response)

        response = client.faculty_committees('abc123')

        expect(response).to be_present
        expect(response[:success]).to be true
        expect(response[:data]).to be_present
        expect(response[:data]).to eq([{ id: 1, name: 'Millennium Scholar' }])
      end
    end

    context 'when the API returns no committees' do
      it 'expects success with empty list' do
        fake_response = instance_double(HTTParty::Response,
                                        success?: true,
                                        parsed_response: [])

        allow(HTTParty).to receive(:post).and_return(fake_response)

        response = client.faculty_committees('abc123')

        expect(response).to be_present
        expect(response[:success]).to be true
        expect(response[:data]).to eq([])
      end
    end

    context 'when the API key is invalid' do
      it 'expects CommitteeRecordsClientError with status code' do
        fake_response = instance_double(HTTParty::Response,
                                        success?: false,
                                        code: 401,
                                        parsed_response: { 'error' => 'Invalid API key' })

        allow(HTTParty).to receive(:post).and_return(fake_response)

        expect do
          client.faculty_committees('abc123')
        end.to raise_error(Etda::CommitteeRecordsClient::CommitteeRecordsClientError, /HTTP 401.*Invalid API key/)
      end
    end

    context 'when a network timeout occurs' do
      it 'expects CommitteeRecordsClientError wrapping the timeout' do
        allow(HTTParty).to receive(:post).and_raise(Timeout::Error, 'execution expired')

        expect do
          client.faculty_committees('abc123')
        end.to raise_error(Etda::CommitteeRecordsClient::CommitteeRecordsClientError, /API request failed.*execution expired/)
      end
    end

    context 'when an HTTParty error occurs' do
      it 'expects CommitteeRecordsClientError wrapping the error' do
        allow(HTTParty).to receive(:post).and_raise(HTTParty::Error, 'Connection failed')

        expect do
          client.faculty_committees('abc123')
        end.to raise_error(Etda::CommitteeRecordsClient::CommitteeRecordsClientError, /API request failed.*Connection failed/)
      end
    end

    context 'when posting to the correct URL with headers' do
      it 'verifies the HTTParty.post call' do
        fake_response = instance_double(HTTParty::Response,
                                        success?: true,
                                        parsed_response: [])

        expect(HTTParty).to receive(:post).and_return(fake_response).with(
          "#{url}/api/v1/committee_records/faculty_committees",
          hash_including(
            headers: {
              'X-API-KEY' => api_token,
              'Content-Type' => 'application/json'
            },
            body: { access_id: 'test_access_id' }.to_json
          )
        )

        client.faculty_committees('test_access_id')
      end
    end
  end
end
