require 'integration/integrations_helper'

# In order to test this, you must comment out "if Rails.env == 'production'"
# in ai_integration controller.  Also need to un xit the spec.
RSpec.describe AiIntegrationController do

  let(:passcode) do
    Rails.application.config_for(:integration_passcode)[:passcode]
  end

  xit "rescues StandardErrors in production and displays the error", type: :feature do
    allow(Rails).to receive(:env) { "production".inquiry }
    visit ai_integration_path
    expect(page).to have_content("AI-Integration")
    within('#congrant') do
      page.fill_in 'passcode', :with => passcode
      click_on 'Beta'
    end
    expect(page).to have_content("undefined method `original_filename' for nil:NilClass")
    expect(page).to have_current_path(ai_integration_path)
  end
end
