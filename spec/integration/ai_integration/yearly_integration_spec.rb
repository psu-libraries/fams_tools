require 'integration/integrations_helper'

describe '#yearly_integrate' do
  let!(:faculty_1) { Faculty.create(access_id: 'abc123') }
  let!(:faculty_2) { Faculty.create(access_id: 'def456') }
  let!(:integration) { FactoryBot.create(:integration) }
  let(:passcode) { Rails.application.config_for(:integration_passcode)[:passcode] }
  let(:yearly_file) { fixture_file_upload('spec/fixtures/yearly_data.xlsx') }

  before do
    stub_request(:post, 'https://betawebservices.digitalmeasures.com/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-University')
      .with(headers: {
              'Content-Type' => 'text/xml'
            })
      .to_return(status: 200, body: '', headers: {})
  end

  context 'when passcode is supplied and beta integration is clicked', js: true, type: :feature do
    it 'integrates yearly data into AI beta' do
      visit ai_integration_path
      select('Yearly Integration', from: 'label_integration_type').select_option
      puts page.driver.console_messages
      logger = double('logger')
      allow(Logger).to receive(:new).and_return(logger)
      expect(logger).to receive(:info).with(/initiated at:|Errors for Yearly/).twice
      expect(logger).not_to receive(:error)
      expect(page).to have_content('Yearly Integration')
      within('#yearly') do
        page.attach_file 'yearly_file', Rails.root.join('spec/fixtures/yearly_data.xlsx')
        page.fill_in 'passcode', with: passcode
        click_on 'Beta'
      end
      expect(page).to have_content('Integration completed')
    end

    it 'redirects when wrong passcode supplied' do
      visit ai_integration_path
      select('Yearly Integration', from: 'label_integration_type').select_option
      within('#yearly') do
        page.attach_file 'yearly_file', Rails.root.join('spec/fixtures/yearly_data.xlsx')
        click_on 'Beta'
      end
      expect(page).to have_content('Wrong Passcode')
    end
  end
end
