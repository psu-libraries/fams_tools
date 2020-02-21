require 'integration/integrations_helper'

describe "#cv_pub_integrate" do
  let!(:faculty_1) {
    Faculty.create(access_id: 'ljs123',
                   user_id:   '123456',
                   f_name:    'Larry',
                   l_name:    'Smith',
                   m_name:    '',
                   college:   'BA')
  }
  let!(:faculty_2) {
    Faculty.create(access_id: 'ajl123',
                   user_id:   '345678',
                   f_name:    'Abraham',
                   l_name:    'Lincoln',
                   m_name:    '',
                   college:   'LA')
  }
  let!(:integration) { FactoryBot.create :integration }
  let(:passcode) {
    Rails.application.config_for(:integration_passcode)[:passcode]
  }

  before do
    @cv_pubs = fixture_file_upload('spec/fixtures/cv_pub.csv')

    stub_request(:post, "https://betawebservices.digitalmeasures.com/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-University").
        with(
            body: cv_pubs_body,
            headers: {
                'Content-Type'=>'text/xml'
            }).
        to_return(status: 200, body: error_message, headers: {})
  end

  context 'when CV Publications Integration is selected', type: :feature, js: true do
    it "gets cv publication data sends data to activity insight" do
      visit ai_integration_path
      select("CV Publications Integration", from: "label_integration_type").select_option
      logger = double('logger')
      allow(Logger).to receive(:new).and_return(logger)
      expect(logger).to receive(:info).with(/initiated at:|Errors for CV Publications/).twice
      expect(logger).to receive(:error).with([/Unexpected EOF in prolog/])
      expect(page).to have_content("AI-Integration")
      within('#cv_publications') do
        page.attach_file 'cv_pub_file', Rails.root.join('spec/fixtures/cv_pub.csv')
        page.fill_in 'passcode', :with => passcode
        click_on 'Beta'
      end
      expect(page).to have_content("Integration completed")
    end

    it "redirects when wrong passcode supplied" do
      visit ai_integration_path
      select("CV Publications Integration", from: "label_integration_type").select_option
      expect(page).to have_content("AI-Integration")
      within('#cv_publications') do
        click_on 'Beta'
      end
      expect(page).to have_content("Wrong Passcode")
    end
  end

  private

  def cv_pubs_body
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<Data>\n  <Record username=\"ljs123\">\n    <INTELLCONT>\n      <TITLE access=\"READ_ONLY\">Test Title 1</TITLE>\n      <CONTYPE access=\"READ_ONLY\">Journal Article</CONTYPE>\n      <JOURNAL_NAME access=\"READ_ONLY\">Test Journal 1</JOURNAL_NAME>\n      <VOLUME access=\"READ_ONLY\">1</VOLUME>\n      <DTY_PUB access=\"READ_ONLY\">2012</DTY_PUB>\n      <EDITION access=\"READ_ONLY\">2</EDITION>\n      <PAGENUM access=\"READ_ONLY\">30-40</PAGENUM>\n      <INSTITUTION access=\"READ_ONLY\">Penn State</INSTITUTION>\n      <PUBCTYST access=\"READ_ONLY\">State College, PA</PUBCTYST>\n      <INTELLCONT_AUTH>\n        <FACULTY_NAME access=\"READ_ONLY\">123456</FACULTY_NAME>\n      </INTELLCONT_AUTH>\n      <INTELLCONT_AUTH>\n        <FNAME access=\"READ_ONLY\">B.</FNAME>\n        <MNAME access=\"READ_ONLY\">B.</MNAME>\n        <LNAME access=\"READ_ONLY\">Bob</LNAME>\n      </INTELLCONT_AUTH>\n      <INTELLCONT_AUTH>\n        <FNAME access=\"READ_ONLY\">F.</FNAME>\n        <MNAME access=\"READ_ONLY\">W.</MNAME>\n        <LNAME access=\"READ_ONLY\">Reynolds</LNAME>\n      </INTELLCONT_AUTH>\n    </INTELLCONT>\n    <INTELLCONT>\n      <TITLE access=\"READ_ONLY\">Test Title 2</TITLE>\n      <CONTYPE access=\"READ_ONLY\">Journal Article</CONTYPE>\n      <JOURNAL_NAME access=\"READ_ONLY\">Test Journal 2</JOURNAL_NAME>\n      <VOLUME access=\"READ_ONLY\">2</VOLUME>\n      <DTY_PUB access=\"READ_ONLY\">2013</DTY_PUB>\n      <EDITION access=\"READ_ONLY\">3</EDITION>\n      <PAGENUM access=\"READ_ONLY\">40-50</PAGENUM>\n      <INSTITUTION access=\"READ_ONLY\">Penn State</INSTITUTION>\n      <PUBCTYST access=\"READ_ONLY\">State College, PA</PUBCTYST>\n      <INTELLCONT_AUTH>\n        <FACULTY_NAME access=\"READ_ONLY\">123456</FACULTY_NAME>\n      </INTELLCONT_AUTH>\n      <INTELLCONT_AUTH>\n        <FNAME access=\"READ_ONLY\">B.</FNAME>\n        <MNAME access=\"READ_ONLY\">B.</MNAME>\n        <LNAME access=\"READ_ONLY\">Bob</LNAME>\n      </INTELLCONT_AUTH>\n    </INTELLCONT>\n  </Record>\n</Data>\n"
  end

  def error_message
    '<?xml version="1.0" encoding="UTF-8"?>

<Error>The following errors were detected:
  <Message>Unexpected EOF in prolog at [row,col {unknown-source}]: [1,0] Nested exception: Unexpected EOF in prolog at [row,col {unknown-source}]: [1,0]</Message>
</Error>'
  end
end