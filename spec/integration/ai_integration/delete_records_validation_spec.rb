require 'integration/integrations_helper'

describe '#delete_records_validation' do
  let!(:integration) { FactoryBot.create(:integration) }
  let(:passcode) { Rails.application.config_for(:integration_passcode)[:passcode] }

  context 'when using a valid resource', :js, type: :feature do
    before do
      stub_request(:post, 'https://betawebservices.digitalmeasures.com/login/service/v4/SchemaData:delete/INDIVIDUAL-ACTIVITIES-University')
        .with(
          body: "<?xml version=\"1.0\"?>\n<Data>\n  <CONGRANT>\n    <item id=\"204643792896\"/>\n    <item id=\"204643794944\"/>\n    <item id=\"204644020224\"/>\n    <item id=\"204644018176\"/>\n    <item id=\"204644022272\"/>\n    <item id=\"204644024320\"/>\n    <item id=\"204644263936\"/>\n  </CONGRANT>\n</Data>\n",
          headers: {
            'Content-Type' => 'text/xml'
          }
        )
        .to_return(status: 200, body: '', headers: {})
    end

    it 'successfullies complete integration' do
      visit ai_integration_path
      expect(page).to have_content('AI-Integration')
      select('Delete Records', from: 'label_integration_type').select_option
      within('#delete_records') do
        page.fill_in 'resource', with: 'CONGRANT'
        page.attach_file 'ids_file', Rails.root.join('spec/fixtures/delete.csv')
        page.fill_in 'passcode', with: passcode
        click_on 'Beta'
      end
      expect(page).to have_content('Integration completed in')
    end
  end

  context 'when using an invalid resource', :js, type: :feature do
    it 'raises an invalid resource error' do
      visit ai_integration_path
      expect(page).to have_content('AI-Integration')
      select('Delete Records', from: 'label_integration_type').select_option
      within('#delete_records') do
        page.fill_in 'resource', with: 'a'
        page.attach_file 'ids_file', Rails.root.join('spec/fixtures/delete.csv')
        page.fill_in 'passcode', with: passcode
        click_on 'Beta'
      end
      expect(page).to have_content('Invalid Resource')
    end
  end
end
