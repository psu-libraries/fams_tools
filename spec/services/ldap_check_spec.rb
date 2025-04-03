require 'rails_helper'

RSpec.describe LdapCheck, type: :service do
  let(:should_disable) { true }
  let(:ldap_check) { LdapCheck.new(ai_disable_client) }
  let(:ai_disable_client) { instance_double(AiDisableClient) }
  let(:mock_ldap_entries) do
    [
      { 'uid' => ['test123'], 'eduPersonPrimaryAffiliation' => ['MEMBER'], 'displayName' => ['Test User'], 'title' => ['Test Title'], 'psBusinessArea' => ['Test Dept'], 'psCampus' => ['Test Campus'] },
      { 'uid' => ['test456'], 'eduPersonPrimaryAffiliation' => ['NON-MEMBER'], 'displayName' => ['Another User'], 'title' => ['Another Title'], 'psBusinessArea' => ['Another Dept'], 'psCampus' => ['Another Campus'] }
    ]
  end

  before do
    allow(ldap_check).to receive(:pull_ldap_data).and_return(mock_ldap_entries)
    allow(ai_disable_client).to receive(:enable_user).and_return(nil)
    allow(ai_disable_client).to receive(:user) do |uid|
      { 'User' => { 'uid' => uid } }
    end
  end

  describe '#check' do
    context 'when CSV has valid usernames' do
      let(:csv_data) { file_fixture('usernames.csv').open }

      it 'disables members when they are enabled' do
        allow(ai_disable_client).to receive(:user) do |uid|
          { 'User' => { 'uid' => uid } }
        end

        result = ldap_check.check(csv_data, should_disable)
        expect(result[:output]).to include('Username,Name,Primary Affiliation,Title,Department,Campus,Disabled?')
        expect(result[:output]).to include('test123,Test User,MEMBER,Test Title,Test Dept,Test Campus,yes')
        expect(result[:output]).to include('test456,Another User,NON-MEMBER,Another Title,Another Dept,Another Campus,no')
      end

      it 'keeps disabled entries disabled' do
        allow(ai_disable_client).to receive(:user) do |uid|
          if uid == 'test123'
            { 'User' => { 'uid' => uid, 'enabled' => 'false' } }
          else
            { 'User' => { 'uid' => uid } }
          end
        end

        result = ldap_check.check(csv_data, should_disable)
        expect(result[:output]).to include('Username,Name,Primary Affiliation,Title,Department,Campus,Disabled?')
        expect(result[:output]).to include('test123,Test User,MEMBER,Test Title,Test Dept,Test Campus,yes')
        expect(result[:output]).to include('test456,Another User,NON-MEMBER,Another Title,Another Dept,Another Campus,no')
      end
    end

    context 'when CSV has no usernames' do
      let(:csv_data) { file_fixture('empty_usernames.csv').open }

      it 'returns an error message' do
        result = ldap_check.check(csv_data, should_disable)
        expect(result[:error]).to be_present
      end
    end

    context 'when CSV has a bad column' do
      let(:csv_data) { file_fixture('bad_userames.csv').open }

      it 'returns an error message' do
        result = ldap_check.check(csv_data, should_disable)
        expect(result[:error]).to be_present
      end
    end

    context 'when should_disable is false' do
      let(:csv_data) { file_fixture('usernames.csv').open }
      let(:should_disable) { false }

      it 'does not disable any users and returns output' do
        result = ldap_check.check(csv_data, should_disable)
        expect(result[:output]).to include('Username,Name,Primary Affiliation,Title,Department,Campus,Disabled?')
        expect(result[:output]).to include('test123,Test User,MEMBER,Test Title,Test Dept,Test Campus,no')
        expect(result[:output]).to include('test456,Another User,NON-MEMBER,Another Title,Another Dept,Another Campus,no')
        expect(ai_disable_client).not_to receive(:enable_user)
      end
    end
  end
end
