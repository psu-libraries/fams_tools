require 'rails_helper'

RSpec.describe LdapCheckController, type: :controller do
  describe '#index' do
    it 'renders the index template' do
      get :index
      expect(response).to render_template(:index)
    end
  end

  describe '#create' do
    let(:csv_file) { fixture_file_upload('spec/fixtures/usernames.csv', 'text/csv') }
    let(:empty_csv_file) { fixture_file_upload('spec/fixtures/empty_usernames.csv', 'text/csv') }
    let(:ldap_entries) do
      [
        {
          'uid' => ['test123'],
          'displayName' => ['Test User'],
          'eduPersonPrimaryAffiliation' => ['MEMBER'],
          'title' => ['Staff'],
          'psBusinessArea' => ['IT'],
          'psCampus' => ['UP']
        }
      ]
    end

    before do
      allow_any_instance_of(Net::LDAP).to receive(:search).and_return(ldap_entries)
    end

    context 'with valid CSV file' do
      it 'generates and sends CSV data' do
        post :create, params: { ldap_check_file: csv_file }

        expect(response.headers['Content-Type']).to eq 'text/csv'
        expect(response.headers['Content-Disposition']).to include 'attachment; filename="ldap_check_results.csv"'
      end

      it 'disables users when should_disable is true' do
        client = instance_double(AiDisableClient)
        allow(AiDisableClient).to receive(:new).and_return(client)
        allow(client).to receive(:user)
        allow(client).to receive(:enable_user)

        post :create, params: {
          ldap_check_file: csv_file,
          ldap_should_disable: '1'
        }

        expect(client).to receive(:enable_user).with('test123', false)
      end
    end

    context 'with invalid CSV file' do
      it 'redirects with error when no usernames found' do
        post :create, params: { ldap_check_file: empty_csv_file }

        expect(flash[:error]).to eq 'No usernames were found in uploaded CSV. Make sure there is a "Usernames" column.'
        expect(response).to redirect_to(ldap_check_path)
      end
    end
  end
end
