require 'integration/integrations_helper'

describe "#com_quality_integrate" do
  let!(:faculty1) do
    Faculty.create(access_id: 'abc123',
                  user_id:   '123456',
                  f_name:    'Bruce',
                  l_name:    'Wayne',
                  m_name:    'Bill',
                  com_id:    'batman',
                  college:   'MD')
  end

  let!(:faculty2) do
    Faculty.create(access_id: 'xyz123',
                  user_id:   '923456',
                  f_name:    'Peter',
                  l_name:    'Parker',
                  m_name:    'Not Bill',
                  com_id:    'spiderman',
                  college:   'MD')
  end
  let!(:integration) { FactoryBot.create :integration }
  let(:passcode) {
    Rails.application.config_for(:integration_passcode)[:passcode]
  }

  context 'when COM Quality Integration is selected', type: :feature, js: true do
    before do
      stub_request(:post, "https://betawebservices.digitalmeasures.com/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-University").
      with(
        body: "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<Data>\n  <Record PennStateHealthUsername=\"batman\">\n    <COURSE_EVAL>\n      <COURSE_YEAR access=\"READ_ONLY\">1938-1939</COURSE_YEAR>\n      <COURSE_NAME access=\"READ_ONLY\">Endocrinology/Reproductive</COURSE_NAME>\n      <EVAL_NAME access=\"READ_ONLY\">Lecture</EVAL_NAME>\n      <RATING_AVG access=\"READ_ONLY\">4.2</RATING_AVG>\n      <NUM_EVAL access=\"READ_ONLY\">1939</NUM_EVAL>\n    </COURSE_EVAL>\n  </Record>\n  <Record PennStateHealthUsername=\"spiderman\">\n    <COURSE_EVAL>\n      <COURSE_YEAR access=\"READ_ONLY\">1962-1963</COURSE_YEAR>\n      <COURSE_NAME access=\"READ_ONLY\">Swinging</COURSE_NAME>\n      <EVAL_NAME access=\"READ_ONLY\">Lecture</EVAL_NAME>\n      <RATING_AVG access=\"READ_ONLY\">5.0</RATING_AVG>\n      <NUM_EVAL access=\"READ_ONLY\">575</NUM_EVAL>\n    </COURSE_EVAL>\n  </Record>\n</Data>\n",
        headers: {
        'Accept'=>'*/*',
        'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
        'Content-Type'=>'text/xml',
        'User-Agent'=>'Ruby'
        }).
      to_return(status: 200, body: error_message, headers: {})

    end

    it "takes COM Quality file, parses, and send data to activity insight" do
      visit ai_integration_path
      select("COM Quality Integration", from: "label_integration_type").select_option
      logger = double('logger')
      allow(Logger).to receive(:new).and_return(logger)
      expect(logger).to receive(:info).with(/initiated at:|Errors for College of Medicine Integration: Quality/).twice
      expect(logger).to receive(:error).with("Affected Faculty: [\"batman\", \"spiderman\"]")
      expect(logger).to receive(:error).with(/_______________________/)
      expect(logger).to receive(:error).with(/<Message>Unexpected EOF in/)
      expect(page).to have_content("AI-Integration")
      within('#com_quality') do
        page.attach_file 'com_quality_file', Rails.root.join('spec/fixtures/ume_faculty_quality.csv')
        sleep 1
        page.fill_in 'passcode', :with => passcode
        click_on 'Beta'
      end
      expect(page).to have_content("Integration completed")
    end

    it "redirects when wrong passcode supplied" do
      visit ai_integration_path
      select("COM Quality Integration", from: "label_integration_type").select_option
      expect(page).to have_content("AI-Integration")
      within('#com_quality') do
        click_on 'Beta'
      end
      expect(page).to have_content("Wrong Passcode")
    end
  end

  private

  def quality_body
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<Data>\n  <Record PennStateHealthUsername=\"batman\">\n    "+
    "<COURSE_EVAL>\n      <COURSE_YEAR access=\"READ_ONLY\">1938-1939</COURSE_YEAR>\n      "+
    "<COURSE_NAME access=\"READ_ONLY\">Endocrinology/Reproductive</COURSE_NAME>\n      "+
    "<EVAL_NAME access=\"READ_ONLY\">Lecture</EVAL_NAME>\n      <RATING_AVG access=\"READ_ONLY\">4.2</RATING_AVG>\n      "+
    "<NUM_EVAL access=\"READ_ONLY\">1939</NUM_EVAL>\n    </COURSE_EVAL>\n  </Record>\n  <Record PennStateHealthUsername=\"spiderman\">\n    "+
    "<COURSE_EVAL>\n      <COURSE_YEAR access=\"READ_ONLY\">1962-1963</COURSE_YEAR>\n      "+
    "<COURSE_NAME access=\"READ_ONLY\">Swinging</COURSE_NAME>\n      <EVAL_NAME access=\"READ_ONLY\">Lecture</EVAL_NAME>\n      "+
    "<RATING_AVG access=\"READ_ONLY\">5.0</RATING_AVG>\n      <NUM_EVAL access=\"READ_ONLY\">575</NUM_EVAL>\n   "+
    "</COURSE_EVAL>\n  </Record>\n</Data>\n"
  end

  def error_message
    '<?xml version="1.0" encoding="UTF-8"?>

<Error>The following errors were detected:
  <Message>Unexpected EOF in prolog at [row,col {unknown-source}]: [1,0] Nested exception: Unexpected EOF in prolog at [row,col {unknown-source}]: [1,0]</Message>
</Error>'
  end
end
