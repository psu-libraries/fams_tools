require 'rails_helper'
  
RSpec.describe MainController do

  describe "#update_ai_user_data" do
    it "takes psu-users.xls file and updates the user data in the database", type: :feature do
      visit root_path
      expect(page).to have_content("FAMS Tools")
      within("#psu-users") do
        page.attach_file 'psu_users_file', Rails.root.join('spec/fixtures/users.xls')
        page.click_on "Update"
      end
      expect(Faculty.count).to eq(2)
    end
  end
end
