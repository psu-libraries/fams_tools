require 'integration/integrations_helper'

describe "#gpa_integrate" do
  let!(:faculty_1) { Faculty.create(access_id: 'abc123', college:   'LA') }
  let!(:faculty_2) { Faculty.create(access_id: 'def456', college:   'LA') }
  let!(:integration) { FactoryBot.create :integration }
  let(:passcode) { Rails.application.config_for(:integration_passcode)[:passcode] }
  let(:gpa_file) { fixture_file_upload('spec/fixtures/gpa_data.xlsx') }
  before do
    stub_request(:post, "https://betawebservices.digitalmeasures.com/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-University").
        with(headers: {
                'Content-Type'=>'text/xml'
            }).
        to_return(status: 200, body: "", headers: {})
  end

  context "when passcode is supplied and beta integration is clicked", type: :feature, js: true do
    it "integrates gpa data into AI beta" do
      visit ai_integration_path
      select("GPA Integration", from: "label_integration_type").select_option
      puts page.driver.console_messages
      logger = double('logger')
      allow(Logger).to receive(:new).and_return(logger)
      expect(logger).to receive(:info).with(/initiated at:|Errors for GPA/).twice
      expect(logger).not_to receive(:error)
      expect(page).to have_content("GPA Integration")
      within('#gpa') do
        page.attach_file 'gpa_file', Rails.root.join('spec/fixtures/gpa_data.xlsx')
        page.fill_in 'passcode', :with => passcode
        click_on 'Beta'
      end
      expect(page).to have_content("Integration completed")
    end

    it "redirects when wrong passcode supplied" do
      visit ai_integration_path
      select("GPA Integration", from: "label_integration_type").select_option
      within('#gpa') do
        page.attach_file 'gpa_file', Rails.root.join('spec/fixtures/gpa_data.xlsx')
        click_on 'Beta'
      end
      expect(page).to have_content("Wrong Passcode")
    end
  end
end
