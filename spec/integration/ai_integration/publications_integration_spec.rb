require 'integration/integrations_helper'

describe '#pub_integrate' do
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

  context 'when RMD Publications Integration is selected', :js, type: :feature do
    before do
      @pub_ajl123 = File.read('spec/fixtures/metadata_pub_ajl123.json').to_s
      @pub_ljs123 = File.read('spec/fixtures/metadata_pub_ljs123.json').to_s

      stub_request(:get, 'https://metadata.libraries.psu.edu/v1/users/ajl123/publications')
        .with(
          body: '',
          headers: {
            'Accept' => 'application/json'
          }
        )
        .to_return(status: 200, body: @pub_ajl123, headers: {})

      stub_request(:get, 'https://metadata.libraries.psu.edu/v1/users/ljs123/publications')
        .with(
          body: '',
          headers: {
            'Accept' => 'application/json'
          }
        )
        .to_return(status: 200, body: @pub_ljs123, headers: {})

      stub_request(:post, 'https://betawebservices.digitalmeasures.com/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-University')
        .with(
          body: pubs_body,
          headers: {
            'Content-Type' => 'text/xml'
          }
        )
        .to_return(status: 200, body: error_message, headers: {})
    end

    it 'gets publication data sends data to activity insight by college' do
      visit ai_integration_path
      select('RMD Publications Integration', from: 'label_integration_type').select_option
      logger = double('logger')
      allow(Logger).to receive(:new).and_return(logger)
      expect(logger).to receive(:info).with(/initiated at:|Errors for Publications/).twice
      expect(logger).to receive(:error).exactly(3).times
      expect(page).to have_content('AI-Integration')
      within('#publications') do
        page.fill_in 'passcode', with: passcode
        find("select[name='college']").find(:option, 'All Colleges').select_option
        click_on 'Beta'
      end
      expect(page).to have_content('Integration completed')
    end

    it 'gets publication data sends data to activity insight by user' do
      visit ai_integration_path
      select('RMD Publications Integration', from: 'label_integration_type').select_option
      logger = double('logger')
      allow(Logger).to receive(:new).and_return(logger)
      expect(logger).to receive(:info).with(/initiated at:|Errors for Publications/).twice
      expect(logger).to receive(:error).exactly(3).times
      expect(page).to have_content('AI-Integration')
      within('#publications') do
        page.fill_in 'passcode', with: passcode
        fill_in 'access_id', with: 'ljs123'
        click_on 'Beta'
      end
      expect(page).to have_content('Integration completed')
    end

    it 'redirects when wrong passcode supplied' do
      visit ai_integration_path
      select('RMD Publications Integration', from: 'label_integration_type').select_option
      expect(page).to have_content('AI-Integration')
      within('#publications') do
        click_on 'Beta'
      end
      expect(page).to have_content('Wrong Passcode')
    end
  end

  private

  def pubs_body
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<Data>\n  <Record username=\"ljs123\">\n    <INTELLCONT>\n      <TITLE access=\"READ_ONLY\">Title2</TITLE>\n      <TITLE_SECONDARY access=\"READ_ONLY\">Secondary Title2</TITLE_SECONDARY>\n      <CONTYPE access=\"READ_ONLY\">Journal Article</CONTYPE>\n      <STATUS access=\"READ_ONLY\">Published</STATUS>\n      <JOURNAL_NAME access=\"READ_ONLY\">Another Journal</JOURNAL_NAME>\n      <VOLUME access=\"READ_ONLY\">2</VOLUME>\n      <DTY_PUB access=\"READ_ONLY\">2016</DTY_PUB>\n      <DTM_PUB access=\"READ_ONLY\">January</DTM_PUB>\n      <DTD_PUB access=\"READ_ONLY\">12</DTD_PUB>\n      <PAGENUM access=\"READ_ONLY\">200-250</PAGENUM>\n      <INTELLCONT_AUTH>\n        <FACULTY_NAME access=\"READ_ONLY\">123456</FACULTY_NAME>\n      </INTELLCONT_AUTH>\n      <INTELLCONT_AUTH>\n        <FNAME access=\"READ_ONLY\">Larry J.</FNAME>\n        <LNAME access=\"READ_ONLY\">Smith</LNAME>\n      </INTELLCONT_AUTH>\n      <RMD_ID>2222</RMD_ID>\n    </INTELLCONT>\n  </Record>\n</Data>\n"
  end

  def error_message
    '<?xml version="1.0" encoding="UTF-8"?>

<Error>The following errors were detected:
  <Message>Unexpected EOF in prolog at [row,col {unknown-source}]: [1,0] Nested exception: Unexpected EOF in prolog at [row,col {unknown-source}]: [1,0]</Message>
</Error>'
  end
end
