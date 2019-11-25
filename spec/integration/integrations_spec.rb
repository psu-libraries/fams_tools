require 'rails_helper'

RSpec.describe AiIntegrationController do

  before(:each) do
    Faculty.create(access_id: 'ljs123',
                   user_id:   '123456',
                   f_name:    'Larry',
                   l_name:    'Smith',
                   m_name:    '',
                   college:   'BA')
    Faculty.create(access_id: 'ajl123',
                   user_id:   '345678',
                   f_name:    'Abraham',
                   l_name:    'Lincoln',
                   m_name:    '',
                   college:   'LA')
  end

  before :each do 
    @contract_grants = fixture_file_upload('spec/fixtures/contract_grants.xlsx')
    @congrant_backup = fixture_file_upload('spec/fixtures/congrant_backup.txt')
    @courses = fixture_file_upload('spec/fixtures/schteach.txt')
    @cv_pubs = fixture_file_upload('spec/fixtures/cv_pub.csv')
    @pubs = File.read('spec/fixtures/metadata_pub_json.json').to_s
  end

  let(:passcode) do
    Rails.application.config_for(:integration_passcode)[:passcode]
  end

  describe "#osp_integrate" do

    before do

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

    it "runs integration of contract/grants" do
      params = { congrant_file: @contract_grants, ai_backup_file: @congrant_backup, passcode: passcode, "target" => :beta }
      post ai_integration_osp_integrate_path, params: params
    end

    it "takes contract/grant file, parses, and send data to activity insight", type: :feature do
      visit ai_integration_path
      expect(page).to have_content("AI-Integration")
      within('#congrant') do 
        page.attach_file 'congrant_file', Rails.root.join('spec/fixtures/contract_grants.xlsx')
        page.attach_file 'ai_backup_file', Rails.root.join('spec/fixtures/congrant_backup.txt')
        page.fill_in 'passcode', :with => passcode
        click_on 'Beta'
      end
      expect(page).to have_content("Integration completed")
      expect(page).to have_content("Unexpected EOF")
    end

    it "redirects when wrong passcode supplied", type: :feature do
      visit ai_integration_path
      expect(page).to have_content("AI-Integration")
      within('#congrant') do 
        click_on 'Beta'
      end
      expect(page).to have_content("Wrong Passcode")
    end
  end

  describe "#lionpath_integrate" do
    before do

      stub_request(:post, "https://betawebservices.digitalmeasures.com/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-University").
         with(
           body: courses_body,
           headers: {
       	  'Content-Type'=>'text/xml'
           }).
         to_return(status: 200, body: error_message, headers: {})
    end

    it "runs integration of courses taught data" do
      params = { courses_file: @courses, "target" => :beta }
      post ai_integration_lionpath_integrate_path, params: params
    end

    it "takes lionpath file, parses, and send data to activity insight", type: :feature do
      visit ai_integration_path
      expect(page).to have_content("AI-Integration")
      within('#courses') do 
        page.attach_file 'courses_file', Rails.root.join('spec/fixtures/schteach.txt')
        page.fill_in 'passcode', :with => passcode
        click_on 'Beta'
      end
      expect(page).to have_content("Integration completed")
      expect(page).to have_content("Unexpected EOF")
    end

    it "redirects when wrong passcode supplied", type: :feature do
      visit ai_integration_path
      expect(page).to have_content("AI-Integration")
      within('#courses') do 
        click_on 'Beta'
      end
      expect(page).to have_content("Wrong Passcode")
    end
  end

  describe "#pub_integrate" do
    before do
      stub_request(:post, "https://metadata.libraries.psu.edu/v1/users/publications").
        with(
          body: "[\"ajl123\", \"ljs123\"]",
          headers: {
              'Accept'=>'application/json',
              'Content-Type'=>'application/json'
          }).
        to_return(status: 200, body: @pubs, headers: {})

      stub_request(:post, "https://betawebservices.digitalmeasures.com/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-University").
        with(
          body: pubs_body,
          headers: {
            'Content-Type'=>'text/xml'
          }).
        to_return(status: 200, body: error_message, headers: {})
    end

    it "runs integration of publication data" do
      params = { "target" => :beta }
      post ai_integration_pub_integrate_path, params: params
    end

    it "gets publication data sends data to activity insight", type: :feature do
      visit ai_integration_path
      expect(page).to have_content("AI-Integration")
      within('#publications') do 
        page.fill_in 'passcode', :with => passcode
        find("select[name='college']").find(:option, 'All Colleges').select_option
        click_on 'Beta'
      end
      expect(page).to have_content("Integration completed")
      expect(page).to have_content("Unexpected EOF")
    end

    it "redirects when wrong passcode supplied", type: :feature do
      visit ai_integration_path
      expect(page).to have_content("AI-Integration")
      within('#publications') do 
        click_on 'Beta'
      end
      expect(page).to have_content("Wrong Passcode")
    end
  end

  describe "#cv_pub_integrate" do
    before do
         stub_request(:post, "https://betawebservices.digitalmeasures.com/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-University").
         with(
           body: cv_pubs_body,
           headers: {
       	  'Content-Type'=>'text/xml'
           }).
         to_return(status: 200, body: error_message, headers: {})
    end

    it "runs integration of cv publication data" do
      params = { cv_pub_file: @cv_pubs, "target" => :beta }
      post ai_integration_cv_pub_integrate_path, params: params
    end

    it "gets cv publication data sends data to activity insight", type: :feature do
      visit ai_integration_path
      expect(page).to have_content("AI-Integration")
      within('#cv_publications') do 
        page.attach_file 'cv_pub_file', Rails.root.join('spec/fixtures/cv_pub.csv')
        page.fill_in 'passcode', :with => passcode
        click_on 'Beta'
      end
      expect(page).to have_content("Integration completed")
      expect(page).to have_content("Unexpected EOF")
    end

    it "redirects when wrong passcode supplied", type: :feature do
      visit ai_integration_path
      expect(page).to have_content("AI-Integration")
      within('#cv_publications') do 
        click_on 'Beta'
      end
      expect(page).to have_content("Wrong Passcode")
    end
  end

  describe "#cv_presentation_integrate" do
    before do
         stub_request(:post, "https://betawebservices.digitalmeasures.com/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-University").
         with(
           body: cv_presentations_body,
           headers: {
       	  'Content-Type'=>'text/xml'
           }).
         to_return(status: 200, body: error_message, headers: {})
    end

    it "runs integration of cv presentation data" do
      params = { cv_presentation_file: @cv_presntations, "target" => :beta }
      post ai_integration_cv_presentation_integrate_path, params: params
    end

    it "gets cv presentation data and sends data to activity insight", type: :feature do
      visit ai_integration_path
      expect(page).to have_content("AI-Integration")
      within('#cv_presentations') do 
        page.attach_file 'cv_presentation_file', Rails.root.join('spec/fixtures/cv_presentation.csv')
        page.fill_in 'passcode', :with => passcode
        click_on 'Beta'
      end
      expect(page).to have_content("Integration completed")
      expect(page).to have_content("Unexpected EOF")
    end

    it "redirects when wrong passcode supplied", type: :feature do
      visit ai_integration_path
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

  def congrant_body
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<Data>\n  <Record username=\"ljs123\">\n    <CONGRANT>\n      <OSPKEY access=\"READ_ONLY\">54321</OSPKEY>\n      <BASE_AGREE access=\"READ_ONLY\"/>\n      <TYPE access=\"READ_ONLY\"/>\n      <TITLE access=\"READ_ONLY\">Title 2</TITLE>\n      <SPONORG access=\"READ_ONLY\">Some Other Sponsor</SPONORG>\n      <AWARDORG access=\"READ_ONLY\">Federal Agencies</AWARDORG>\n      <CONGRANT_INVEST>\n        <FACULTY_NAME>123456</FACULTY_NAME>\n        <FNAME>Larry</FNAME>\n        <MNAME/>\n        <LNAME>Smith</LNAME>\n        <ROLE>Co-Principal Investigator</ROLE>\n        <ASSIGN>50</ASSIGN>\n      </CONGRANT_INVEST>\n      <AMOUNT_REQUEST access=\"READ_ONLY\">25</AMOUNT_REQUEST>\n      <AMOUNT_ANTICIPATE access=\"READ_ONLY\">4</AMOUNT_ANTICIPATE>\n      <AMOUNT access=\"READ_ONLY\">3</AMOUNT>\n      <STATUS access=\"READ_ONLY\">Awarded</STATUS>\n      <DTM_SUB access=\"READ_ONLY\">December</DTM_SUB>\n      <DTD_SUB access=\"READ_ONLY\">14</DTD_SUB>\n      <DTY_SUB access=\"READ_ONLY\">2015</DTY_SUB>\n      <DTM_AWARD/>\n      <DTD_AWARD/>\n      <DTY_AWARD/>\n      <DTM_START access=\"READ_ONLY\">June</DTM_START>\n      <DTD_START access=\"READ_ONLY\">01</DTD_START>\n      <DTY_START access=\"READ_ONLY\">2015</DTY_START>\n      <DTM_END access=\"READ_ONLY\">May</DTM_END>\n      <DTD_END access=\"READ_ONLY\">31</DTD_END>\n      <DTY_END access=\"READ_ONLY\">2015</DTY_END>\n      <DTM_DECLINE/>\n      <DTD_DECLINE/>\n      <DTY_DECLINE/>\n    </CONGRANT>\n  </Record>\n  <Record username=\"ajl123\">\n    <CONGRANT>\n      <OSPKEY access=\"READ_ONLY\">12345</OSPKEY>\n      <BASE_AGREE access=\"READ_ONLY\"/>\n      <TYPE access=\"READ_ONLY\"/>\n      <TITLE access=\"READ_ONLY\">Title 1</TITLE>\n      <SPONORG access=\"READ_ONLY\">Some Sponsor</SPONORG>\n      <AWARDORG access=\"READ_ONLY\">Federal Agencies</AWARDORG>\n      <CONGRANT_INVEST>\n        <FACULTY_NAME>345678</FACULTY_NAME>\n        <FNAME>Abraham</FNAME>\n        <MNAME/>\n        <LNAME>Lincoln</LNAME>\n        <ROLE>Principal Investigator</ROLE>\n        <ASSIGN>100</ASSIGN>\n      </CONGRANT_INVEST>\n      <AMOUNT_REQUEST access=\"READ_ONLY\">10000</AMOUNT_REQUEST>\n      <AMOUNT_ANTICIPATE access=\"READ_ONLY\">10</AMOUNT_ANTICIPATE>\n      <AMOUNT access=\"READ_ONLY\">1</AMOUNT>\n      <STATUS access=\"READ_ONLY\">Awarded</STATUS>\n      <DTM_SUB access=\"READ_ONLY\">November</DTM_SUB>\n      <DTD_SUB access=\"READ_ONLY\">15</DTD_SUB>\n      <DTY_SUB access=\"READ_ONLY\">2015</DTY_SUB>\n      <DTM_AWARD/>\n      <DTD_AWARD/>\n      <DTY_AWARD/>\n      <DTM_START access=\"READ_ONLY\">January</DTM_START>\n      <DTD_START access=\"READ_ONLY\">01</DTD_START>\n      <DTY_START access=\"READ_ONLY\">2015</DTY_START>\n      <DTM_END access=\"READ_ONLY\">December</DTM_END>\n      <DTD_END access=\"READ_ONLY\">31</DTD_END>\n      <DTY_END access=\"READ_ONLY\">2015</DTY_END>\n      <DTM_DECLINE/>\n      <DTD_DECLINE/>\n      <DTY_DECLINE/>\n    </CONGRANT>\n  </Record>\n</Data>\n"
  end

  def courses_body
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<Data>\n  <Record username=\"ljs123\">\n    <SCHTEACH>\n      <TYT_TERM access=\"READ_ONLY\">Fall</TYT_TERM>\n      <TYY_TERM access=\"READ_ONLY\">2016</TYY_TERM>\n      <TITLE access=\"READ_ONLY\">Title 1</TITLE>\n      <DESC access=\"READ_ONLY\">Description of the course.</DESC>\n      <COURSEPRE access=\"READ_ONLY\">1</COURSEPRE>\n      <COURSENUM access=\"READ_ONLY\">101</COURSENUM>\n      <COURSENUM_SUFFIX access=\"READ_ONLY\">B</COURSENUM_SUFFIX>\n      <SECTION access=\"READ_ONLY\">004</SECTION>\n      <CAMPUS access=\"READ_ONLY\">UP</CAMPUS>\n      <ENROLL access=\"READ_ONLY\">33</ENROLL>\n      <XCOURSE_COURSEPRE access=\"READ_ONLY\"/>\n      <XCOURSE_COURSENUM access=\"READ_ONLY\"/>\n      <XCOURSE_COURSENUM_SUFFIX access=\"READ_ONLY\"/>\n      <RESPON access=\"READ_ONLY\">100</RESPON>\n      <CHOURS access=\"READ_ONLY\">3</CHOURS>\n      <INST_MODE access=\"READ_ONLY\">In Person</INST_MODE>\n      <COURSE_COMP access=\"READ_ONLY\">Lecture</COURSE_COMP>\n      <ROLE access=\"READ_ONLY\">Primary Instructor</ROLE>\n    </SCHTEACH>\n    <SCHTEACH>\n      <TYT_TERM access=\"READ_ONLY\">Fall</TYT_TERM>\n      <TYY_TERM access=\"READ_ONLY\">2017</TYY_TERM>\n      <TITLE access=\"READ_ONLY\">Title 2</TITLE>\n      <DESC access=\"READ_ONLY\">Description of this course2.</DESC>\n      <COURSEPRE access=\"READ_ONLY\">1</COURSEPRE>\n      <COURSENUM access=\"READ_ONLY\">002</COURSENUM>\n      <COURSENUM_SUFFIX access=\"READ_ONLY\"/>\n      <SECTION access=\"READ_ONLY\">001</SECTION>\n      <CAMPUS access=\"READ_ONLY\">UP</CAMPUS>\n      <ENROLL access=\"READ_ONLY\">1</ENROLL>\n      <XCOURSE_COURSEPRE access=\"READ_ONLY\"/>\n      <XCOURSE_COURSENUM access=\"READ_ONLY\"/>\n      <XCOURSE_COURSENUM_SUFFIX access=\"READ_ONLY\"/>\n      <RESPON access=\"READ_ONLY\">100</RESPON>\n      <CHOURS access=\"READ_ONLY\">Variable</CHOURS>\n      <INST_MODE access=\"READ_ONLY\">In Person</INST_MODE>\n      <COURSE_COMP access=\"READ_ONLY\">Lecture</COURSE_COMP>\n      <ROLE access=\"READ_ONLY\">Primary Instructor</ROLE>\n    </SCHTEACH>\n  </Record>\n  <Record username=\"ajl123\">\n    <SCHTEACH>\n      <TYT_TERM access=\"READ_ONLY\">Fall</TYT_TERM>\n      <TYY_TERM access=\"READ_ONLY\">2017</TYY_TERM>\n      <TITLE access=\"READ_ONLY\">Title 2</TITLE>\n      <DESC access=\"READ_ONLY\">Description of this course2.</DESC>\n      <COURSEPRE access=\"READ_ONLY\">1</COURSEPRE>\n      <COURSENUM access=\"READ_ONLY\">021</COURSENUM>\n      <COURSENUM_SUFFIX access=\"READ_ONLY\">C</COURSENUM_SUFFIX>\n      <SECTION access=\"READ_ONLY\">002</SECTION>\n      <CAMPUS access=\"READ_ONLY\">WC</CAMPUS>\n      <ENROLL access=\"READ_ONLY\">23</ENROLL>\n      <XCOURSE_COURSEPRE access=\"READ_ONLY\"/>\n      <XCOURSE_COURSENUM access=\"READ_ONLY\"/>\n      <XCOURSE_COURSENUM_SUFFIX access=\"READ_ONLY\"/>\n      <RESPON access=\"READ_ONLY\">100</RESPON>\n      <CHOURS access=\"READ_ONLY\">4</CHOURS>\n      <INST_MODE access=\"READ_ONLY\">Web</INST_MODE>\n      <COURSE_COMP access=\"READ_ONLY\">Lecture</COURSE_COMP>\n      <ROLE access=\"READ_ONLY\">Primary Instructor</ROLE>\n    </SCHTEACH>\n  </Record>\n</Data>\n"
  end

  def pubs_body
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<Data>\n  <Record username=\"ljs123\">\n    <INTELLCONT>\n      <TITLE access=\"READ_ONLY\">Title2</TITLE>\n      <TITLE_SECONDARY access=\"READ_ONLY\">Secondary Title2</TITLE_SECONDARY>\n      <CONTYPE access=\"READ_ONLY\">Journal Article, Academic Journal</CONTYPE>\n      <STATUS access=\"READ_ONLY\">Published</STATUS>\n      <JOURNAL_NAME access=\"READ_ONLY\">Another Journal</JOURNAL_NAME>\n      <VOLUME access=\"READ_ONLY\">2</VOLUME>\n      <DTY_PUB access=\"READ_ONLY\">2016</DTY_PUB>\n      <DTM_PUB access=\"READ_ONLY\">January (1st Quarter/Winter)</DTM_PUB>\n      <DTD_PUB access=\"READ_ONLY\">12</DTD_PUB>\n      <ABSTRACT access=\"READ_ONLY\">This is an abstract.</ABSTRACT>\n      <PAGENUM access=\"READ_ONLY\">200-250</PAGENUM>\n      <CITATION_COUNT access=\"READ_ONLY\">1</CITATION_COUNT>\n      <INTELLCONT_AUTH>\n        <FACULTY_NAME access=\"READ_ONLY\">123456</FACULTY_NAME>\n      </INTELLCONT_AUTH>\n      <INTELLCONT_AUTH>\n        <FNAME access=\"READ_ONLY\">Larry J.</FNAME>\n        <LNAME access=\"READ_ONLY\">Smith</LNAME>\n      </INTELLCONT_AUTH>\n    </INTELLCONT>\n  </Record>\n</Data>\n"
  end

  def cv_pubs_body
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<Data>\n  <Record username=\"ljs123\">\n    <INTELLCONT>\n      <TITLE access=\"READ_ONLY\">Test Title 1</TITLE>\n      <CONTYPE access=\"READ_ONLY\">Journal Article</CONTYPE>\n      <JOURNAL_NAME access=\"READ_ONLY\">Test Journal 1</JOURNAL_NAME>\n      <VOLUME access=\"READ_ONLY\">1</VOLUME>\n      <DTY_PUB access=\"READ_ONLY\">2012</DTY_PUB>\n      <EDITION access=\"READ_ONLY\">2</EDITION>\n      <PAGENUM access=\"READ_ONLY\">30-40</PAGENUM>\n      <INSTITUTION access=\"READ_ONLY\">Penn State</INSTITUTION>\n      <PUBCTYST access=\"READ_ONLY\">State College, PA</PUBCTYST>\n      <INTELLCONT_AUTH>\n        <FACULTY_NAME access=\"READ_ONLY\">123456</FACULTY_NAME>\n      </INTELLCONT_AUTH>\n      <INTELLCONT_AUTH>\n        <FNAME access=\"READ_ONLY\">B.</FNAME>\n        <MNAME access=\"READ_ONLY\">B.</MNAME>\n        <LNAME access=\"READ_ONLY\">Bob</LNAME>\n      </INTELLCONT_AUTH>\n      <INTELLCONT_AUTH>\n        <FNAME access=\"READ_ONLY\">F.</FNAME>\n        <MNAME access=\"READ_ONLY\">W.</MNAME>\n        <LNAME access=\"READ_ONLY\">Reynolds</LNAME>\n      </INTELLCONT_AUTH>\n    </INTELLCONT>\n    <INTELLCONT>\n      <TITLE access=\"READ_ONLY\">Test Title 2</TITLE>\n      <CONTYPE access=\"READ_ONLY\">Journal Article</CONTYPE>\n      <JOURNAL_NAME access=\"READ_ONLY\">Test Journal 2</JOURNAL_NAME>\n      <VOLUME access=\"READ_ONLY\">2</VOLUME>\n      <DTY_PUB access=\"READ_ONLY\">2013</DTY_PUB>\n      <EDITION access=\"READ_ONLY\">3</EDITION>\n      <PAGENUM access=\"READ_ONLY\">40-50</PAGENUM>\n      <INSTITUTION access=\"READ_ONLY\">Penn State</INSTITUTION>\n      <PUBCTYST access=\"READ_ONLY\">State College, PA</PUBCTYST>\n      <INTELLCONT_AUTH>\n        <FACULTY_NAME access=\"READ_ONLY\">123456</FACULTY_NAME>\n      </INTELLCONT_AUTH>\n      <INTELLCONT_AUTH>\n        <FNAME access=\"READ_ONLY\">B.</FNAME>\n        <MNAME access=\"READ_ONLY\">B.</MNAME>\n        <LNAME access=\"READ_ONLY\">Bob</LNAME>\n      </INTELLCONT_AUTH>\n    </INTELLCONT>\n  </Record>\n</Data>\n"
  end

  def cv_presentations_body
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<Data>\n  <Record username=\"ljs123\">\n    <PRESENT>\n      <TITLE access=\"READ_ONLY\">Presentation 1</TITLE>\n      <DTY_END access=\"READ_ONLY\">2016</DTY_END>\n      <NAME access=\"READ_ONLY\">Conference 1</NAME>\n      <ORG access=\"READ_ONLY\">Penn State</ORG>\n      <LOCATION access=\"READ_ONLY\">State College, PA</LOCATION>\n      <PRESENT_AUTH>\n        <FACULTY_NAME>123456</FACULTY_NAME>\n      </PRESENT_AUTH>\n      <PRESENT_AUTH>\n        <FNAME access=\"READ_ONLY\">B.</FNAME>\n        <MNAME access=\"READ_ONLY\">B.</MNAME>\n        <LNAME access=\"READ_ONLY\">Bob</LNAME>\n      </PRESENT_AUTH>\n      <PRESENT_AUTH>\n        <FNAME access=\"READ_ONLY\">F.</FNAME>\n        <MNAME access=\"READ_ONLY\">W.</MNAME>\n        <LNAME access=\"READ_ONLY\">Reynolds</LNAME>\n      </PRESENT_AUTH>\n    </PRESENT>\n    <PRESENT>\n      <TITLE access=\"READ_ONLY\">Presentation 2</TITLE>\n      <DTY_END access=\"READ_ONLY\">2009</DTY_END>\n      <NAME access=\"READ_ONLY\">Conference 2</NAME>\n      <ORG access=\"READ_ONLY\">Penn State</ORG>\n      <LOCATION access=\"READ_ONLY\">State College, PA</LOCATION>\n      <PRESENT_AUTH>\n        <FACULTY_NAME>123456</FACULTY_NAME>\n      </PRESENT_AUTH>\n      <PRESENT_AUTH>\n        <FNAME access=\"READ_ONLY\">B.</FNAME>\n        <MNAME access=\"READ_ONLY\">B.</MNAME>\n        <LNAME access=\"READ_ONLY\">Bob</LNAME>\n      </PRESENT_AUTH>\n    </PRESENT>\n  </Record>\n</Data>\n"
  end
end
