require 'rails_helper'

RSpec.describe AiIntegrationController do

  before do
    Faculty.create(access_id: 'abc123', college:   'LA')
    Faculty.create(access_id: 'def456', college:   'LA')
  end

  let(:passcode) { Rails.application.config_for(:integration_passcode)[:passcode] }
  let(:gpa_file) { fixture_file_upload('spec/fixtures/gpa_data.xlsx') }

  describe "#gpa_integrate" do
    before do
      stub_request(:post, "https://betawebservices.digitalmeasures.com/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-University").
          with(
              body: "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<Data>\n  <Record username=\"abc123\">\n    <GRADE_DIST_GPA>\n      <TYT_TERM>Spring</TYT_TERM>\n      <TYY_TERM>2018</TYY_TERM>\n      <COURSEPRE>CRIM</COURSEPRE>\n      <COURSENUM>111</COURSENUM>\n      <SECTION>002</SECTION>\n      <NUMGRADES>38</NUMGRADES>\n      <STEARNA>1</STEARNA>\n      <STEARNAMINUS>6</STEARNAMINUS>\n      <STEARNBPLUS>13</STEARNBPLUS>\n      <STEARNB>12</STEARNB>\n      <STEARNBMINUS>2</STEARNBMINUS>\n      <STEARNCPLUS>4</STEARNCPLUS>\n      <STEARNC>0</STEARNC>\n      <STEARND>0</STEARND>\n      <STEARNF>0</STEARNF>\n      <STEARNW>0</STEARNW>\n      <STEARNL>12</STEARNL>\n      <STEARNOTHER>0</STEARNOTHER>\n      <GPA>3.16</GPA>\n    </GRADE_DIST_GPA>\n    <GRADE_DIST_GPA>\n      <TYT_TERM>Spring</TYT_TERM>\n      <TYY_TERM>2018</TYY_TERM>\n      <COURSEPRE>PSY</COURSEPRE>\n      <COURSENUM>225</COURSENUM>\n      <SECTION>23</SECTION>\n      <NUMGRADES>45</NUMGRADES>\n      <STEARNA>16</STEARNA>\n      <STEARNAMINUS>4</STEARNAMINUS>\n      <STEARNBPLUS>5</STEARNBPLUS>\n      <STEARNB>5</STEARNB>\n      <STEARNBMINUS>7</STEARNBMINUS>\n      <STEARNCPLUS>2</STEARNCPLUS>\n      <STEARNC>2</STEARNC>\n      <STEARND>2</STEARND>\n      <STEARNF>2</STEARNF>\n      <STEARNW>1</STEARNW>\n      <STEARNL>4</STEARNL>\n      <STEARNOTHER>0</STEARNOTHER>\n      <GPA>3.1</GPA>\n    </GRADE_DIST_GPA>\n  </Record>\n  <Record username=\"def456\">\n    <GRADE_DIST_GPA>\n      <TYT_TERM>Spring</TYT_TERM>\n      <TYY_TERM>2018</TYY_TERM>\n      <COURSEPRE>AFAM</COURSEPRE>\n      <COURSENUM>102</COURSENUM>\n      <COURSENUM_SUFFIX>C</COURSENUM_SUFFIX>\n      <SECTION>001</SECTION>\n      <NUMGRADES>17</NUMGRADES>\n      <STEARNA>5</STEARNA>\n      <STEARNAMINUS>2</STEARNAMINUS>\n      <STEARNBPLUS>3</STEARNBPLUS>\n      <STEARNB>5</STEARNB>\n      <STEARNBMINUS>0</STEARNBMINUS>\n      <STEARNCPLUS>0</STEARNCPLUS>\n      <STEARNC>0</STEARNC>\n      <STEARND>1</STEARND>\n      <STEARNF>1</STEARNF>\n      <STEARNW>1</STEARNW>\n      <STEARNL>2</STEARNL>\n      <STEARNOTHER>0</STEARNOTHER>\n      <GPA>3.14</GPA>\n    </GRADE_DIST_GPA>\n  </Record>\n</Data>\n",
              headers: {
                  'Content-Type'=>'text/xml'
              }).
          to_return(status: 200, body: "", headers: {})
    end

    context "when passcode is supplied and beta integration is clicked", type: :feature do
      it "integrates gpa data into AI beta" do
        visit ai_integration_path
        expect(page).to have_content("GPA Integration")
        within('#gpa') do
          page.attach_file 'gpa_file', Rails.root.join('spec/fixtures/gpa_data.xlsx')
          page.fill_in 'passcode', :with => passcode
          click_on 'Beta'
        end
        expect(page).to have_content("Integration completed")
      end

      it "redirects when wrong passcode supplied", type: :feature do
        visit ai_integration_path
        within('#gpa') do
          page.attach_file 'gpa_file', Rails.root.join('spec/fixtures/gpa_data.xlsx')
          click_on 'Beta'
        end
        expect(page).to have_content("Wrong Passcode")
      end
    end
  end
end
