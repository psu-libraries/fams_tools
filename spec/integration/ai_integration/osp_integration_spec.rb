require 'integration/integrations_helper'

describe "#osp_integrate" do
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

  context 'when Contract/Grant Integration is selected', type: :feature, js: true do
    before do
      @contract_grants = fixture_file_upload('spec/fixtures/contract_grants.xlsx')
      @congrant_backup = fixture_file_upload('spec/fixtures/congrant_backup.txt')

      stub_request(:post, "https://betawebservices.digitalmeasures.com/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-University").
          with(
              body: congrant_body,
              headers: {
                  'Content-Type'=>'text/xml'
              }).
          to_return(status: 200, body: error_message, headers: {})

      stub_request(:post, "https://betawebservices.digitalmeasures.com/login/service/v4/SchemaData:delete/INDIVIDUAL-ACTIVITIES-University").
          with(
              body: "<?xml version=\"1.0\"?>\n<Data>\n  <CONGRANT/>\n</Data>\n",
              headers: {
                  'Content-Type'=>'text/xml'
              }).
          to_return(status: 200, body: "", headers: {})
    end

    it "takes contract/grant file, parses, and send data to activity insight" do
      visit ai_integration_path
      select("Contract/Grant Integration", from: "label_integration_type").select_option
      logger = double('logger')
      allow(Logger).to receive(:new).and_return(logger)
      expect(logger).to receive(:info).with(/Errors for Contract\/Grant/)
      expect(logger).to receive(:error).with([/Unexpected EOF in prolog/])
      expect(page).to have_content("AI-Integration")
      within('#congrant') do
        page.attach_file 'congrant_file', Rails.root.join('spec/fixtures/contract_grants.xlsx')
        page.attach_file 'ai_backup_file', Rails.root.join('spec/fixtures/congrant_backup.txt')
        page.fill_in 'passcode', :with => passcode
        click_on 'Beta'
      end
      expect(page).to have_content("Integration completed")
    end

    it "redirects when wrong passcode supplied" do
      visit ai_integration_path
      select("Contract/Grant", from: "label_integration_type").select_option
      expect(page).to have_content("AI-Integration")
      within('#congrant') do
        click_on 'Beta'
      end
      expect(page).to have_content("Wrong Passcode")
    end
  end

  private

  def congrant_body
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<Data>\n  <Record username=\"ljs123\">\n    <CONGRANT>\n      <OSPKEY access=\"READ_ONLY\">54321</OSPKEY>\n      <BASE_AGREE access=\"READ_ONLY\"/>\n      <TYPE access=\"READ_ONLY\"/>\n      <TITLE access=\"READ_ONLY\">Title 2</TITLE>\n      <SPONORG access=\"READ_ONLY\">Some Other Sponsor</SPONORG>\n      <AWARDORG access=\"READ_ONLY\">Federal Agencies</AWARDORG>\n      <CONGRANT_INVEST>\n        <FACULTY_NAME>123456</FACULTY_NAME>\n        <FNAME>Larry</FNAME>\n        <MNAME/>\n        <LNAME>Smith</LNAME>\n        <ROLE>Co-Principal Investigator</ROLE>\n        <ASSIGN>50</ASSIGN>\n      </CONGRANT_INVEST>\n      <AMOUNT_REQUEST access=\"READ_ONLY\">25</AMOUNT_REQUEST>\n      <AMOUNT_ANTICIPATE access=\"READ_ONLY\">4</AMOUNT_ANTICIPATE>\n      <AMOUNT access=\"READ_ONLY\">3</AMOUNT>\n      <STATUS access=\"READ_ONLY\">Awarded</STATUS>\n      <DTM_SUB access=\"READ_ONLY\">December</DTM_SUB>\n      <DTD_SUB access=\"READ_ONLY\">14</DTD_SUB>\n      <DTY_SUB access=\"READ_ONLY\">2015</DTY_SUB>\n      <DTM_AWARD/>\n      <DTD_AWARD/>\n      <DTY_AWARD/>\n      <DTM_START access=\"READ_ONLY\">June</DTM_START>\n      <DTD_START access=\"READ_ONLY\">01</DTD_START>\n      <DTY_START access=\"READ_ONLY\">2015</DTY_START>\n      <DTM_END access=\"READ_ONLY\">May</DTM_END>\n      <DTD_END access=\"READ_ONLY\">31</DTD_END>\n      <DTY_END access=\"READ_ONLY\">2015</DTY_END>\n      <DTM_DECLINE/>\n      <DTD_DECLINE/>\n      <DTY_DECLINE/>\n    </CONGRANT>\n  </Record>\n  <Record username=\"ajl123\">\n    <CONGRANT>\n      <OSPKEY access=\"READ_ONLY\">12345</OSPKEY>\n      <BASE_AGREE access=\"READ_ONLY\"/>\n      <TYPE access=\"READ_ONLY\"/>\n      <TITLE access=\"READ_ONLY\">Title 1</TITLE>\n      <SPONORG access=\"READ_ONLY\">Some Sponsor</SPONORG>\n      <AWARDORG access=\"READ_ONLY\">Federal Agencies</AWARDORG>\n      <CONGRANT_INVEST>\n        <FACULTY_NAME>345678</FACULTY_NAME>\n        <FNAME>Abraham</FNAME>\n        <MNAME/>\n        <LNAME>Lincoln</LNAME>\n        <ROLE>Principal Investigator</ROLE>\n        <ASSIGN>100</ASSIGN>\n      </CONGRANT_INVEST>\n      <AMOUNT_REQUEST access=\"READ_ONLY\">10000</AMOUNT_REQUEST>\n      <AMOUNT_ANTICIPATE access=\"READ_ONLY\">10</AMOUNT_ANTICIPATE>\n      <AMOUNT access=\"READ_ONLY\">1</AMOUNT>\n      <STATUS access=\"READ_ONLY\">Awarded</STATUS>\n      <DTM_SUB access=\"READ_ONLY\">November</DTM_SUB>\n      <DTD_SUB access=\"READ_ONLY\">15</DTD_SUB>\n      <DTY_SUB access=\"READ_ONLY\">2015</DTY_SUB>\n      <DTM_AWARD/>\n      <DTD_AWARD/>\n      <DTY_AWARD/>\n      <DTM_START access=\"READ_ONLY\">January</DTM_START>\n      <DTD_START access=\"READ_ONLY\">01</DTD_START>\n      <DTY_START access=\"READ_ONLY\">2015</DTY_START>\n      <DTM_END access=\"READ_ONLY\">December</DTM_END>\n      <DTD_END access=\"READ_ONLY\">31</DTD_END>\n      <DTY_END access=\"READ_ONLY\">2015</DTY_END>\n      <DTM_DECLINE/>\n      <DTD_DECLINE/>\n      <DTY_DECLINE/>\n    </CONGRANT>\n  </Record>\n</Data>\n"
  end

  def error_message
    '<?xml version="1.0" encoding="UTF-8"?>

<Error>The following errors were detected:
  <Message>Unexpected EOF in prolog at [row,col {unknown-source}]: [1,0] Nested exception: Unexpected EOF in prolog at [row,col {unknown-source}]: [1,0]</Message>
</Error>'
  end
end