require 'rails_helper'
require_relative '../../../lib/etda/committee_records_client'
RSpec.describe Etda::CommitteeRecordsClient do
  let(:client) { Etda::CommitteeRecordsClient.new }

  # This is to instansiate the client
  describe '#faculty_committees' do
    context 'when valid API KEY and user has committees' do
      it 'returns committee member JSON' do
        # Create a mock test but with a respone returned as a JSON

        fake_response = instance_double(HTTParty::Response,
                                        success?: true,
                                        parsed_response: [{ id: 1, name: 'Millennium Scholar' }])

        allow(HTTParty).to receive(:post).and_return(fake_response)

        # Calling the method and checking if the test works
        response = client.faculty_committees('abc123')

        expect(response).to be_present
        expect(response[:success]).to be true
        expect(response[:data]).to be_present
      end
    end

    context 'when user has no committees' do
      it 'returns empty committee' do
        # Create a mock test but with no response
        fake_response = instance_double(HTTParty::Response,
                                        success?: true,
                                        parsed_response: [])

        allow(HTTParty).to receive(:post).and_return(fake_response)

        response = client.faculty_committees(' ')

        expect(response).to be_present
        expect(response[:success]).to be true
        expect(response[:data]).to eq([])
      end
    end

    # Checking for when key is invalid
    context 'when API key is invalid' do
      it 'raises a committee records client error' do
        fake_response = instance_double(HTTParty::Response,
                                        success?: false,
                                        parsed_response: { 'error' => 'Invalid API key' })

        allow(HTTParty).to receive(:post).and_return(fake_response)

        expect do
          client.faculty_committees('invalid_key')
        end.to raise_error(Etda::CommitteeRecordsClient::CommitteeRecordsClientError)
      end
    end

    # Checking when a timeout occurs
    context 'when a timeout occurs' do
      it 'raises a committee records client error' do
        allow(HTTParty).to receive(:post).and_raise(Timeout::Error)

        expect do
          client.faculty_committees('timeout_test')
        end.to raise_error(Etda::CommitteeRecordsClient::CommitteeRecordsClientError)
      end
    end
  end
end
