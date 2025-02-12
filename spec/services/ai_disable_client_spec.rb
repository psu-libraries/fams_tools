require 'rails_helper'

RSpec.describe AiDisableClient, type: :service do
  let(:client) { AiDisableClient.new }
  let(:uid) { 'user1' }

  before do
    stub_request(:get, /betawebservices.digitalmeasures.com/)
      .to_return(status: 200, body: "<User><Username>#{uid}</Username></User>", headers: { 'Content-Type' => 'text/xml' })

    stub_request(:put, /betawebservices.digitalmeasures.com/)
      .to_return(status: 200, body: "", headers: { 'Content-Type' => 'text/xml' })
  end

  describe '#user' do
    it 'fetches user data' do
      response = client.user(uid)
      expect(response.body).to include("<Username>#{uid}</Username>")
    end
  end

  describe '#enable_user' do
    it 'sends a request to enable or disable a user' do
      response = client.enable_user(uid, false)
      expect(response.code).to eq(200)
    end
  end
end