require 'rails_helper'

RSpec.describe AiIntegrationController do

  before(:each) do
    Faculty.create(access_id: 'ajk5603',
                   user_id:   '123456',
                   f_name:    'A',
                   l_name:    'K',
                   m_name:    'J',
                   college:   'EN')
  end

  let(:passcode) do
    Rails.application.config_for(:integration_passcode)[:passcode]
  end

  before do
    allow(STDOUT).to receive(:puts)
  end

  describe "#ldap_integrate" do

    before do
      stub_request(:post, "https://beta.digitalmeasures.com/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-University").
         with(
           body: "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<Data>\n  <Record username=\"ajk5603\">\n    <PCI>\n      <EMAIL>ajk5603@psu.edu</EMAIL>\n      <FNAME>A</FNAME>\n      <MNAME>J</MNAME>\n      <LNAME>K</LNAME>\n    </PCI>\n  </Record>\n</Data>\n",
           headers: {
       	  'Content-Type'=>'text/xml'
           }).
         to_return(status: 200, body: "", headers: {})
    end

    it "runs integration of personal contact info" do
      params = { passcode: passcode, "target" => :beta }
      post ai_integration_ldap_integrate_path, params: params
    end

    it "gets ldap data and sends data to activity insight", type: :feature do
      visit ai_integration_path
      expect(page).to have_content("AI-Integration")
      within('#personal_contacts') do
        page.fill_in 'passcode', :with => passcode
        click_on 'Beta'
      end
      expect(page).to have_content("Integration completed")
    end

    it "redirects when wrong passcode supplied", type: :feature do
      visit ai_integration_path
      expect(page).to have_content("AI-Integration")
      within('#personal_contacts') do
        click_on 'Beta'
      end
      expect(page).to have_content("Wrong Passcode")
    end
  end
end
