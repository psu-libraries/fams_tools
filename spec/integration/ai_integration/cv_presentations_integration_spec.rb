require 'rails_helper'

describe "#cv_presentation_integrate" do
  let(:faculty_1) {
    Faculty.create(access_id: 'ljs123',
                   user_id:   '123456',
                   f_name:    'Larry',
                   l_name:    'Smith',
                   m_name:    '',
                   college:   'BA')
  }
  let(:faculty_2) {
    Faculty.create(access_id: 'ajl123',
                   user_id:   '345678',
                   f_name:    'Abraham',
                   l_name:    'Lincoln',
                   m_name:    '',
                   college:   'LA')
  }
  let(:passcode) {
    Rails.application.config_for(:integration_passcode)[:passcode]
  }

  before do
       stub_request(:post, "https://betawebservices.digitalmeasures.com/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-University").
       with(
         body: cv_presentations_body,
         headers: {
        'Content-Type'=>'text/xml'
         }).
       to_return(status: 200, body: error_message, headers: {})
  end

  context 'when CV Presentations Integration is selected', type: :feature, js: true do
    it "gets cv presentation data and sends data to activity insight" do
      visit ai_integration_path
      select("CV Presentations Integration", from: "label_integration_type").select_option
      logger = double('logger')
      allow(Logger).to receive(:new).and_return(logger)
      expect(logger).to receive(:info).with(/Errors for CV Presentations/)
      expect(logger).to receive(:error).with([/Unexpected EOF in prolog/])
      expect(page).to have_content("AI-Integration")
      within('#cv_presentations') do
        page.attach_file 'cv_presentation_file', Rails.root.join('spec/fixtures/cv_presentation.csv')
        page.fill_in 'passcode', :with => passcode
        click_on 'Beta'
      end
      expect(page).to have_content("Integration completed")
    end

    it "redirects when wrong passcode supplied" do
      visit ai_integration_path
      select("CV Presentations Integration", from: "label_integration_type").select_option
      expect(page).to have_content("AI-Integration")
      within('#cv_presentations') do
        click_on 'Beta'
      end
      expect(page).to have_content("Wrong Passcode")
    end
  end

  private

  def error_message
    '<?xml version="1.0" encoding="UTF-8"?>

<Error>The following errors were detected:
  <Message>Unexpected EOF in prolog at [row,col {unknown-source}]: [1,0] Nested exception: Unexpected EOF in prolog at [row,col {unknown-source}]: [1,0]</Message>
</Error>'
  end

  def cv_presentations_body
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<Data>\n  <Record username=\"ljs123\">\n    <PRESENT>\n      <TITLE access=\"READ_ONLY\">Presentation 1</TITLE>\n      <DTY_END access=\"READ_ONLY\">2016</DTY_END>\n      <NAME access=\"READ_ONLY\">Conference 1</NAME>\n      <ORG access=\"READ_ONLY\">Penn State</ORG>\n      <LOCATION access=\"READ_ONLY\">State College, PA</LOCATION>\n      <PRESENT_AUTH>\n        <FACULTY_NAME>123456</FACULTY_NAME>\n      </PRESENT_AUTH>\n      <PRESENT_AUTH>\n        <FNAME access=\"READ_ONLY\">B.</FNAME>\n        <MNAME access=\"READ_ONLY\">B.</MNAME>\n        <LNAME access=\"READ_ONLY\">Bob</LNAME>\n      </PRESENT_AUTH>\n      <PRESENT_AUTH>\n        <FNAME access=\"READ_ONLY\">F.</FNAME>\n        <MNAME access=\"READ_ONLY\">W.</MNAME>\n        <LNAME access=\"READ_ONLY\">Reynolds</LNAME>\n      </PRESENT_AUTH>\n    </PRESENT>\n    <PRESENT>\n      <TITLE access=\"READ_ONLY\">Presentation 2</TITLE>\n      <DTY_END access=\"READ_ONLY\">2009</DTY_END>\n      <NAME access=\"READ_ONLY\">Conference 2</NAME>\n      <ORG access=\"READ_ONLY\">Penn State</ORG>\n      <LOCATION access=\"READ_ONLY\">State College, PA</LOCATION>\n      <PRESENT_AUTH>\n        <FACULTY_NAME>123456</FACULTY_NAME>\n      </PRESENT_AUTH>\n      <PRESENT_AUTH>\n        <FNAME access=\"READ_ONLY\">B.</FNAME>\n        <MNAME access=\"READ_ONLY\">B.</MNAME>\n        <LNAME access=\"READ_ONLY\">Bob</LNAME>\n      </PRESENT_AUTH>\n    </PRESENT>\n  </Record>\n</Data>\n"
  end
end
