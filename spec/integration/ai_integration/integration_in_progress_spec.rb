require 'integration/integrations_helper'

RSpec.describe AiIntegrationController do

  context 'when an integration is currently running', type: :feature, js: true do
    it 'does not render submit buttons and displays message' do
      allow_any_instance_of(ApplicationJob::Busy).to receive(:value).and_return 1
      visit ai_integration_path
      select("Contract/Grant Integration", from: "label_integration_type").select_option
      expect(page).to have_content 'An integration is currently in progress'
      expect(page).not_to have_button 'Beta'
      expect(page).not_to have_button 'Production'
      # The following counter needs to be cleared or it will impact other tests
      ApplicationJob::Busy.clear
    end
  end
end
