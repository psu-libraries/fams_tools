require 'rails_helper'

describe "#lionpath_integrate" do
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
    @courses = fixture_file_upload('spec/fixtures/schteach.txt')

    stub_request(:post, "https://betawebservices.digitalmeasures.com/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-University").
        with(
            body: courses_body,
            headers: {
                'Content-Type'=>'text/xml'
            }).
        to_return(status: 200, body: error_message, headers: {})
  end

  context 'when Courses Taught Integration is selected', type: :feature, js: true do
    it "takes lionpath file, parses, and send data to activity insight" do
      visit ai_integration_path
      select("Courses Taught Integration", from: "label_integration_type").select_option
      logger = double('logger')
      allow(Logger).to receive(:new).and_return(logger)
      expect(logger).to receive(:info).with(/Errors for Courses Taught/)
      expect(logger).to receive(:error).with([/Unexpected EOF in prolog/])
      expect(page).to have_content("AI-Integration")
      within('#courses') do
        page.attach_file 'courses_file', Rails.root.join('spec/fixtures/schteach.txt')
        page.fill_in 'passcode', :with => passcode
        click_on 'Beta'
      end
      expect(page).to have_content("Integration completed")
    end

    it "redirects when wrong passcode supplied" do
      visit ai_integration_path
      select("Courses Taught Integration", from: "label_integration_type").select_option
      expect(page).to have_content("AI-Integration")
      within('#courses') do
        click_on 'Beta'
      end
      expect(page).to have_content("Wrong Passcode")
    end
  end

  private

  def courses_body
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<Data>\n  <Record username=\"ljs123\">\n    <SCHTEACH>\n      <TYT_TERM access=\"READ_ONLY\">Fall</TYT_TERM>\n      <TYY_TERM access=\"READ_ONLY\">2016</TYY_TERM>\n      <TITLE access=\"READ_ONLY\">Title 1</TITLE>\n      <DESC access=\"READ_ONLY\">Description of the course.</DESC>\n      <COURSEPRE access=\"READ_ONLY\">1</COURSEPRE>\n      <COURSENUM access=\"READ_ONLY\">101</COURSENUM>\n      <COURSENUM_SUFFIX access=\"READ_ONLY\">B</COURSENUM_SUFFIX>\n      <SECTION access=\"READ_ONLY\">004</SECTION>\n      <CAMPUS access=\"READ_ONLY\">UP</CAMPUS>\n      <ENROLL access=\"READ_ONLY\">33</ENROLL>\n      <XCOURSE_COURSEPRE access=\"READ_ONLY\"/>\n      <XCOURSE_COURSENUM access=\"READ_ONLY\"/>\n      <XCOURSE_COURSENUM_SUFFIX access=\"READ_ONLY\"/>\n      <RESPON access=\"READ_ONLY\">100</RESPON>\n      <CHOURS access=\"READ_ONLY\">3</CHOURS>\n      <INST_MODE access=\"READ_ONLY\">In Person</INST_MODE>\n      <COURSE_COMP access=\"READ_ONLY\">Lecture</COURSE_COMP>\n      <ROLE access=\"READ_ONLY\">Primary Instructor</ROLE>\n    </SCHTEACH>\n    <SCHTEACH>\n      <TYT_TERM access=\"READ_ONLY\">Fall</TYT_TERM>\n      <TYY_TERM access=\"READ_ONLY\">2017</TYY_TERM>\n      <TITLE access=\"READ_ONLY\">Title 2</TITLE>\n      <DESC access=\"READ_ONLY\">Description of this course2.</DESC>\n      <COURSEPRE access=\"READ_ONLY\">1</COURSEPRE>\n      <COURSENUM access=\"READ_ONLY\">002</COURSENUM>\n      <COURSENUM_SUFFIX access=\"READ_ONLY\"/>\n      <SECTION access=\"READ_ONLY\">001</SECTION>\n      <CAMPUS access=\"READ_ONLY\">UP</CAMPUS>\n      <ENROLL access=\"READ_ONLY\">1</ENROLL>\n      <XCOURSE_COURSEPRE access=\"READ_ONLY\"/>\n      <XCOURSE_COURSENUM access=\"READ_ONLY\"/>\n      <XCOURSE_COURSENUM_SUFFIX access=\"READ_ONLY\"/>\n      <RESPON access=\"READ_ONLY\">100</RESPON>\n      <CHOURS access=\"READ_ONLY\">Variable</CHOURS>\n      <INST_MODE access=\"READ_ONLY\">In Person</INST_MODE>\n      <COURSE_COMP access=\"READ_ONLY\">Lecture</COURSE_COMP>\n      <ROLE access=\"READ_ONLY\">Primary Instructor</ROLE>\n    </SCHTEACH>\n  </Record>\n  <Record username=\"ajl123\">\n    <SCHTEACH>\n      <TYT_TERM access=\"READ_ONLY\">Fall</TYT_TERM>\n      <TYY_TERM access=\"READ_ONLY\">2017</TYY_TERM>\n      <TITLE access=\"READ_ONLY\">Title 2</TITLE>\n      <DESC access=\"READ_ONLY\">Description of this course2.</DESC>\n      <COURSEPRE access=\"READ_ONLY\">1</COURSEPRE>\n      <COURSENUM access=\"READ_ONLY\">021</COURSENUM>\n      <COURSENUM_SUFFIX access=\"READ_ONLY\">C</COURSENUM_SUFFIX>\n      <SECTION access=\"READ_ONLY\">002</SECTION>\n      <CAMPUS access=\"READ_ONLY\">WC</CAMPUS>\n      <ENROLL access=\"READ_ONLY\">23</ENROLL>\n      <XCOURSE_COURSEPRE access=\"READ_ONLY\"/>\n      <XCOURSE_COURSENUM access=\"READ_ONLY\"/>\n      <XCOURSE_COURSENUM_SUFFIX access=\"READ_ONLY\"/>\n      <RESPON access=\"READ_ONLY\">100</RESPON>\n      <CHOURS access=\"READ_ONLY\">4</CHOURS>\n      <INST_MODE access=\"READ_ONLY\">Web</INST_MODE>\n      <COURSE_COMP access=\"READ_ONLY\">Lecture</COURSE_COMP>\n      <ROLE access=\"READ_ONLY\">Primary Instructor</ROLE>\n    </SCHTEACH>\n  </Record>\n</Data>\n"
  end

  def error_message
    '<?xml version="1.0" encoding="UTF-8"?>

<Error>The following errors were detected:
  <Message>Unexpected EOF in prolog at [row,col {unknown-source}]: [1,0] Nested exception: Unexpected EOF in prolog at [row,col {unknown-source}]: [1,0]</Message>
</Error>'
  end
end