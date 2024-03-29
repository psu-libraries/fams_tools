require 'integration/integrations_helper'

RSpec.describe AiIntegrationController do
  let!(:integration) { FactoryBot.create(:integration) }

  context 'when an integration is currently running', :js, type: :feature do
    it 'does not render submit buttons and displays message' do
      allow(Integration).to receive(:running?).and_return true
      visit ai_integration_path
      select('Contract/Grant Integration', from: 'label_integration_type').select_option
      expect(page).to have_content 'An integration is currently in progress'
      expect(page).to have_no_button 'Beta'
      expect(page).to have_no_button 'Production'
    end
  end
end
