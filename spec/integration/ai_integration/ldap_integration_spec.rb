require 'integration/integrations_helper'

describe '#ldap_integrate' do
  let!(:faculty_1) do
    Faculty.create(access_id: 'ajk5603',
                   user_id: '123456',
                   f_name: 'A',
                   l_name: 'K',
                   m_name: 'J',
                   college: 'EN')
  end
  let!(:integration) { FactoryBot.create(:integration) }

  let(:passcode) do
    Rails.application.config_for(:integration_passcode)[:passcode]
  end

  before do
    allow_any_instance_of(Net::LDAP).to receive(:search).and_return true
    stub_request(:post, 'https://betawebservices.digitalmeasures.com/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-University')
      .with(
        body: "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<Data>\n  <Record username=\"ajk5603\">\n    <PCI>\n      <EMAIL>ajk5603@psu.edu</EMAIL>\n      <FNAME>A</FNAME>\n      <MNAME>J</MNAME>\n      <LNAME>K</LNAME>\n    </PCI>\n  </Record>\n</Data>\n",
        headers: {
          'Content-Type' => 'text/xml'
        }
      )
      .to_return(status: 200, body: 'Success', headers: {})
  end

  context 'when Personal & Contact Integration is selected', :js, type: :feature do
    it 'gets ldap data and sends data to activity insight' do
      visit ai_integration_path
      select('Personal & Contact Integration', from: 'label_integration_type').select_option
      logger = double('logger')
      allow(Logger).to receive(:new).and_return(logger)
      expect(logger).to receive(:info).with(/initiated at:|Errors for Personal & Contact In/).twice
      expect(logger).not_to receive(:error)
      expect(page).to have_content('AI-Integration')
      within('#personal_contacts') do
        page.fill_in 'passcode', with: passcode
        click_on 'Beta'
      end
      expect(page).to have_content('Integration completed')
    end

    it 'redirects when wrong passcode supplied' do
      visit ai_integration_path
      select('Personal & Contact Integration', from: 'label_integration_type').select_option
      expect(page).to have_content('AI-Integration')
      within('#personal_contacts') do
        click_on 'Beta'
      end
      expect(page).to have_content('Wrong Passcode')
    end
  end
end
