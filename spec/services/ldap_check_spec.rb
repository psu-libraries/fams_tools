require 'rails_helper'

RSpec.describe LdapCheck, type: :service do
  let(:should_disable) { true }
  let(:ldap_check) { LdapCheck.new }
  let(:ai_disable_client) { instance_double(AiDisableClient) }
  let(:mock_ldap_entries) do
    [
      { 'uid' => ['test123'], 'eduPersonPrimaryAffiliation' => ['MEMBER'], 'displayName' => ['Test User'], 'title' => ['Test Title'], 'psBusinessArea' => ['Test Dept'], 'psCampus' => ['Test Campus'] }
    ]
  end

  before do
    allow(ldap_check).to receive(:pull_ldap_data).and_return(mock_ldap_entries)
    allow(AiDisableClient).to receive(:new).and_return(ai_disable_client)
    allow(ai_disable_client).to receive(:enable_user)
  end

  describe '#check' do
    context 'when CSV has valid usernames' do
      let(:csv_data) { file_fixture('usernames.csv').open }

      it 'returns output with disabled users' do
        result = ldap_check.check(csv_data, should_disable)
        expect(result[:output]).to include('Username,Name,Primary Affiliation,Title,Department,Campus,Disabled?')
        expect(result[:output]).to include('test123,Test User,MEMBER,Test Title,Test Dept,Test Campus,yes')
      end
    end

    context 'when CSV has no usernames' do
      let(:csv_data) { file_fixture('empty_usernames.csv').open }

      it 'returns an error message' do
        result = ldap_check.check(csv_data, should_disable)
        expect(result[:error]).to eq('No usernames were found in uploaded CSV. Make sure there is a "Usernames" column.')
      end
    end

    context 'when CSV has a bad column' do
      let(:csv_data) { file_fixture('bad_userames.csv').open }

      it 'returns an error message' do
        result = ldap_check.check(csv_data, should_disable)
        expect(result[:error]).to eq('No usernames were found in uploaded CSV. Make sure there is a "Usernames" column.')
      end
    end

    context 'when should_disable is false' do
      let(:csv_data) { file_fixture('usernames.csv').open }
      let(:should_disable) { false }

      it 'does not disable any users and returns output' do
        result = ldap_check.check(csv_data, should_disable)
        expect(result[:output]).to include('Username,Name,Primary Affiliation,Title,Department,Campus,Disabled?')
        expect(result[:output]).to include('test123,Test User,MEMBER,Test Title,Test Dept,Test Campus,no')
        expect(ai_disable_client).not_to receive(:enable_user)
      end
    end
  end
end
