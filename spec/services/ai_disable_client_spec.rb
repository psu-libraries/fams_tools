# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AiDisableClient do
  let(:username) { 'test_username' }
  let(:password) { 'test_password' }
  let(:client) { described_class.new(username, password) }
  let(:uid) { 'user1' }

  describe '#user' do
    let(:response_body) do
      <<~XML
        <?xml version="1.0" encoding="UTF-8"?>
        <User>
          <FirstName>redacted</FirstName>
        </User>
      XML
    end

    context 'when user is found' do
      let(:success_response) do
        instance_double(
          HTTParty::Response,
          code: 200,
          body: response_body
        )
      end

      it 'fetches user data' do
        allow(described_class).to receive(:get)
          .with("/User/USERNAME:#{uid}", hash_including(basic_auth: { username:, password: }))
          .and_return(success_response)

        result = client.user(uid)
        expect(result.body).to include('<FirstName>redacted</FirstName>')
      end
    end
  end

  describe '#enable_user' do
    context 'when enabling or disabling a user' do
      let(:success_response) do
        instance_double(
          HTTParty::Response,
          code: 200,
          body: ''
        )
      end

      it 'sends a request to enable a user' do
        allow(described_class).to receive(:put)
          .with("/User/USERNAME:#{uid}", hash_including(basic_auth: { username:, password: }, body: '<User enabled="true"/>'))
          .and_return(success_response)

        result = client.enable_user(uid, true)
        expect(result.code).to eq(200)
      end

      it 'sends a request to disable a user' do
        allow(described_class).to receive(:put)
          .with("/User/USERNAME:#{uid}", hash_including(basic_auth: { username:, password: }, body: '<User enabled="false"/>'))
          .and_return(success_response)

        result = client.enable_user(uid, false)
        expect(result.code).to eq(200)
      end
    end
  end
end
