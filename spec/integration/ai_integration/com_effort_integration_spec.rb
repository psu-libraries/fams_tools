require 'integration/integrations_helper'

describe '#com_effort_integrate' do
  let!(:faculty1) do
    Faculty.create(access_id: 'xyz123',
                   user_id: '923456',
                   f_name: 'Hermione',
                   l_name: 'Granger',
                   m_name: 'Not Bill',
                   com_id: 'hgranger',
                   college: 'MD')
  end

  let!(:faculty2) do
    Faculty.create(access_id: 'abc123',
                   user_id: '123456',
                   f_name: 'Luke',
                   l_name: 'Skywalker',
                   m_name: 'Bill',
                   com_id: 'lskywalker',
                   college: 'MD')
  end
  let!(:integration) { FactoryBot.create(:integration) }
  let(:passcode) do
    Rails.application.config_for(:integration_passcode)[:passcode]
  end

  context 'when Com Effort Integration is selected', :js, type: :feature do
    before do
      stub_request(:post, 'https://betawebservices.digitalmeasures.com/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-University')
        .with(
          body: effort_body,
          headers: {
            'Accept' => '*/*',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Content-Type' => 'text/xml',
            'User-Agent' => 'Ruby'
          }
        )
        .to_return(status: 200, body: error_message, headers: {})
    end

    it 'takes COM Effort file, parses, and send data to activity insight' do
      visit ai_integration_path
      select('COM Effort Integration', from: 'label_integration_type').select_option
      logger = double('logger')
      allow(Logger).to receive(:new).and_return(logger)
      expect(logger).to receive(:info).with(/initiated at:|Errors for College of Medicine Integration: Effort/).twice
      expect(logger).to receive(:error).with('Affected Faculty: ["hgranger", "lskywalker"]')
      expect(logger).to receive(:error).with(/_______________________/)
      expect(logger).to receive(:error).with(/<Message>Unexpected EOF in/)
      expect(page).to have_content('AI-Integration')
      within('#com_effort') do
        page.attach_file 'com_effort_file', Rails.root.join('spec/fixtures/ume_faculty_effort.csv')
        sleep 1
        page.fill_in 'passcode', with: passcode
        click_on 'Beta'
      end
      expect(page).to have_content('Integration completed')
    end

    it 'redirects when wrong passcode supplied' do
      visit ai_integration_path
      select('COM Effort Integration', from: 'label_integration_type').select_option
      expect(page).to have_content('AI-Integration')
      within('#com_effort') do
        click_on 'Beta'
      end
      expect(page).to have_content('Wrong Passcode')
    end
  end

  private

  def effort_body
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<Data>\n  <Record PennStateHealthUsername=\"hgranger\">\n    " +
      "<INSTRUCT_TAUGHT>\n      <COURSE_YEAR access=\"READ_ONLY\">1997-1998</COURSE_YEAR>\n      " +
      "<COURSE_TITLE access=\"READ_ONLY\">Potions</COURSE_TITLE>\n      " +
      "<EVENT_TITLE access=\"READ_ONLY\">FTF REQ Various Rooms 10-12 PBL - EndoRepro PBL 1402 - Thyroid</EVENT_TITLE>\n      " +
      "<EVENT_TYPE access=\"READ_ONLY\">Sm Grp Facilitation</EVENT_TYPE>\n      " +
      "<DTM_EVENT access=\"READ_ONLY\">June</DTM_EVENT>\n      <DTD_EVENT access=\"READ_ONLY\">26</DTD_EVENT>\n      " +
      "<DTY_EVENT access=\"READ_ONLY\">1997</DTY_EVENT>\n      <CAL_TEACH_HRS access=\"READ_ONLY\">7.0</CAL_TEACH_HRS>\n    " +
      "</INSTRUCT_TAUGHT>\n  </Record>\n  <Record PennStateHealthUsername=\"lskywalker\">\n    <INSTRUCT_TAUGHT>\n      " +
      "<COURSE_YEAR access=\"READ_ONLY\">1976-1977</COURSE_YEAR>\n      " +
      "<COURSE_TITLE access=\"READ_ONLY\">the Force</COURSE_TITLE>\n      " +
      "<EVENT_TITLE access=\"READ_ONLY\">FTF REQ Various Rooms 10-12 PBL - EndoRepro PBL 1402 - Thyroid</EVENT_TITLE>\n      " +
      "<EVENT_TYPE access=\"READ_ONLY\">Lecture</EVENT_TYPE>\n      <DTM_EVENT access=\"READ_ONLY\">May</DTM_EVENT>\n      " +
      "<DTD_EVENT access=\"READ_ONLY\">25</DTD_EVENT>\n      <DTY_EVENT access=\"READ_ONLY\">1977</DTY_EVENT>\n      " +
      "<CAL_TEACH_HRS access=\"READ_ONLY\">2.0</CAL_TEACH_HRS>\n    </INSTRUCT_TAUGHT>\n  </Record>\n</Data>\n"
  end

  def error_message
    '<?xml version="1.0" encoding="UTF-8"?>

<Error>The following errors were detected:
  <Message>Unexpected EOF in prolog at [row,col {unknown-source}]: [1,0] Nested exception: Unexpected EOF in prolog at [row,col {unknown-source}]: [1,0]</Message>
</Error>'
  end
end
