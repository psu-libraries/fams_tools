require 'integration/integrations_helper'

describe '#osp_integrate' do
  let!(:faculty_1) do
    Faculty.create(access_id: 'ljs123',
                   user_id: '123456',
                   f_name: 'Larry',
                   l_name: 'Smith',
                   m_name: '',
                   college: 'BA')
  end
  let!(:faculty_2) do
    Faculty.create(access_id: 'ajl123',
                   user_id: '345678',
                   f_name: 'Abraham',
                   l_name: 'Lincoln',
                   m_name: '',
                   college: 'LA')
  end
  let!(:integration) { FactoryBot.create(:integration) }

  let(:passcode) do
    Rails.application.config_for(:integration_passcode)[:passcode]
  end

  context 'when Contract/Grant Integration is selected', js: true, type: :feature do
    before do
      @contract_grants = fixture_file_upload('spec/fixtures/contract_grants.csv')
      @congrant_backup = fixture_file_upload('spec/fixtures/congrant_backup.csv')

      stub_request(:post, 'https://betawebservices.digitalmeasures.com/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-University')
        .with(
          body: /\?xml version/,
          headers: {
            'Content-Type' => 'text/xml'
          }
        )
        .to_return(status: 200, body: error_message, headers: {})

      stub_request(:post, 'https://betawebservices.digitalmeasures.com/login/service/v4/SchemaData:delete/INDIVIDUAL-ACTIVITIES-University')
        .with(
          body: "<?xml version=\"1.0\"?>\n<Data>\n  <CONGRANT>\n    <item id=\"1000000002\"/>\n    <item id=\"1000000002\"/>\n  </CONGRANT>\n</Data>\n",
          headers: {
            'Content-Type' => 'text/xml'
          }
        )
        .to_return(status: 200, body: '', headers: {})
    end

    it 'takes contract/grant file, parses, and send data to activity insight' do
      visit ai_integration_path
      select('Contract/Grant Integration', from: 'label_integration_type').select_option
      logger = double('logger')
      allow(Logger).to receive(:new).and_return(logger)
      expect(logger).to receive(:info).with(%r{initiated at:|Errors for Contract/Grant}).twice
      expect(logger).to receive(:error).exactly(4).times
      expect(page).to have_content('AI-Integration')
      within('#congrant') do
        page.attach_file 'congrant_file', Rails.root.join('spec/fixtures/contract_grants.csv')
        page.attach_file 'ai_backup_file', Rails.root.join('spec/fixtures/congrant_backup.csv')
        page.fill_in 'passcode', with: passcode
        click_on 'Beta'
      end
      expect(page).to have_content('Integration completed')
    end

    it 'redirects when wrong passcode supplied' do
      visit ai_integration_path
      select('Contract/Grant', from: 'label_integration_type').select_option
      expect(page).to have_content('AI-Integration')
      within('#congrant') do
        click_on 'Beta'
      end
      expect(page).to have_content('Wrong Passcode')
    end
  end

  private

  def error_message
    '<?xml version="1.0" encoding="UTF-8"?>

<Error>The following errors were detected:
  <Message>Unexpected EOF in prolog at [row,col {unknown-source}]: [1,0] Nested exception: Unexpected EOF in prolog at [row,col {unknown-source}]: [1,0]</Message>
</Error>'
  end
end
