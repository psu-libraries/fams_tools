require 'rails_helper'
  
RSpec.describe PublicationListingsController do

  describe "#create" do

    it "takes properly filled out form inputs, parses data, and creates a works record", type: :feature do
      visit publication_listings_path
      expect(page).to have_content("CV Parser")
      within('#publication_listing_form') do
        page.fill_in 'citations_title', :with => 'Title'
        page.fill_in 'username', :with => 'ajk5603'
        page.select "Book", from: 'contype'
        page.fill_in 'citations', :with => '1. Billy, B.O.B., Francis, Y.O., & Vern, S.M. (2001). Computers: Are they smart?  Not as smart as me. Penn State University, College of Engineering.'
        click_on "Create Citation Spreadsheet"
      end
      expect(page).to have_content("Title (1 Records)")
    end
  end
end
