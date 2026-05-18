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

  describe '#faculty_committees_from_all_endpoints' do
    let(:access_id) { 'faculty123' }

    it 'returns results from all 4 endpoints' do
      etda_response = instance_double(HTTParty::Response,
                                      success?: true,
                                      parsed_response: { 'committees' => [{ 'id' => 1, 'student_fname' => 'John' }] })
      honors_response = instance_double(HTTParty::Response,
                                        success?: true,
                                        parsed_response: { 'committees' => [{ 'id' => 2, 'student_fname' => 'Jane' }] })
      ms_response = instance_double(HTTParty::Response,
                                    success?: true,
                                    parsed_response: { 'committees' => [{ 'id' => 3, 'student_fname' => 'Bob' }] })
      sset_response = instance_double(HTTParty::Response,
                                      success?: true,
                                      parsed_response: { 'committees' => [{ 'id' => 4, 'student_fname' => 'Alice' }] })

      allow(HTTParty).to receive(:post).and_return(etda_response, honors_response, ms_response, sset_response)

      result = client.faculty_committees_from_all_endpoints(access_id)

      expect(result).to be_a(Hash)
      expect(result.keys).to contain_exactly(:etda, :honors, :millennium_scholars, :sset)
      expect(result[:etda][:data]['committees'].length).to eq(1)
      expect(result[:honors][:data]['committees'].length).to eq(1)
      expect(result[:millennium_scholars][:data]['committees'].length).to eq(1)
      expect(result[:sset][:data]['committees'].length).to eq(1)
    end

    it 'continues if one endpoint fails' do
      etda_response = instance_double(HTTParty::Response,
                                      success?: true,
                                      parsed_response: { 'committees' => [{ 'id' => 1 }] })
      error_response = instance_double(HTTParty::Response,
                                       success?: false,
                                       parsed_response: { 'error' => 'Not found' })
      ms_response = instance_double(HTTParty::Response,
                                    success?: true,
                                    parsed_response: { 'committees' => [{ 'id' => 3 }] })
      sset_response = instance_double(HTTParty::Response,
                                      success?: true,
                                      parsed_response: { 'committees' => [{ 'id' => 4 }] })

      allow(HTTParty).to receive(:post).and_return(etda_response, error_response, ms_response, sset_response)

      result = client.faculty_committees_from_all_endpoints(access_id)

      expect(result[:etda][:success]).to be(true)
      expect(result[:honors][:success]).to be(false)
      expect(result[:millennium_scholars][:success]).to be(true)
      expect(result[:sset][:success]).to be(true)
    end

    it 'includes endpoint name in result' do
      response = instance_double(HTTParty::Response,
                                 success?: true,
                                 parsed_response: { 'committees' => [] })
      allow(HTTParty).to receive(:post).and_return(response)

      result = client.faculty_committees_from_all_endpoints(access_id)

      result.each do |endpoint_name, endpoint_result|
        expect(endpoint_result[:endpoint]).to eq(endpoint_name)
      end
    end
  end

  describe 'with specific endpoint' do
    it 'fetches from specific endpoint when initialized' do
      client_honors = Etda::CommitteeRecordsClient.new(endpoint: :honors)
      response = instance_double(HTTParty::Response,
                                 success?: true,
                                 parsed_response: { 'committees' => [] })
      allow(HTTParty).to receive(:post).and_return(response)

      result = client_honors.faculty_committees('faculty123')

      expect(result[:success]).to be(true)
    end
  end
end
