require 'rails_helper'

RSpec.describe AiDisableClient do
  let(:client) { described_class.new }
  let(:uid) { 'abc123' }

  describe '#user' do
    context 'when request is successful' do
      before do
        stub_request(:get, "https://betawebservices.digitalmeasures.com/login/service/v4/User/USERNAME:#{uid}")
          .with(
            basic_auth: %w[test_user test_pass],
            headers: {
              'Accept' => 'text/xml',
              'Content-Type' => 'text/xml'
            }
          )
          .to_return(status: 200, body: '<User enabled="true"/>', headers: {})
      end

      it 'returns user data' do
        response = client.user(uid)
        expect(response.code).to eq 200
        expect(response.body).to eq '<User enabled="true"/>'
      end
    end

    context 'when request fails' do
      before do
        stub_request(:get, "https://betawebservices.digitalmeasures.com/login/service/v4/User/USERNAME:#{uid}")
          .to_return(status: 401)
      end

      it 'returns error response' do
        response = client.user(uid)
        expect(response.code).to eq 401
      end
    end
  end

  describe '#enable_user' do
    context 'when request is successful' do
      before do
        stub_request(:put, "https://betawebservices.digitalmeasures.com/login/service/v4/User/USERNAME:#{uid}")
          .with(
            basic_auth: %w[test_user test_pass],
            headers: {
              'Accept' => 'text/xml',
              'Content-Type' => 'text/xml'
            },
            body: '<User enabled="false"/>'
          )
          .to_return(status: 200, body: '', headers: {})
      end

      it 'updates user enabled status' do
        response = client.enable_user(uid, false)
        expect(response.code).to eq 200
      end
    end

    context 'when request fails' do
      before do
        stub_request(:put, "https://betawebservices.digitalmeasures.com/login/service/v4/User/USERNAME:#{uid}")
          .to_return(status: 500)
      end

      it 'returns error response' do
        response = client.enable_user(uid, false)
        expect(response.code).to eq 500
      end
    end
  end
end
