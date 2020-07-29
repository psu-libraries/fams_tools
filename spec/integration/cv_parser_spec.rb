require 'rails_helper'
  
RSpec.describe PublicationListingsController do

  describe "#create" do

    it "takes properly filled out form inputs, parses data, and creates a publication_listing record with works", type: :feature do
      visit publication_listings_path
      expect(page).to have_content("CV Parser")
      within('#publication_listing_form') do
        page.fill_in 'citations_title', :with => 'Title'
        page.fill_in 'username', :with => 'ajk5603'
        page.select "Book", from: 'contype'
        page.fill_in 'citations', :with => '1. Billy, B.O.B., Francis, Y.O., & Vern, S.M. (2001). Computers: Are they smart?  Not as smart as me. Penn State University, College of Engineering.
2. Billy, B.O.B., Francis, Y.O., & Vern, S.M. (2001). Computers: Are they smart?  Not as smart as me. Penn State University, College of Engineering.'
        click_on "Create Citation Spreadsheet"
      end
      expect(PublicationListing.count).to eq(1)
      expect(Work.count).to eq(2)
      expect(Work.first.authors.count).to eq(3)
      expect(Work.first.citation).to match /1. Billy, B.O.B.,/
      expect(page).to have_content("Title (2 Records)")
    end

    context "when a works record exists" do
      before do
        PublicationListing.create!(name: "Test")
      end
      
      it "redirects to works page when link is clicked", type: :feature do
        visit publication_listings_path
        expect(page).to have_content("CV Parser")
        within('#works') do
          click_on "Test"
        end
        expect(current_path).to include('/works')
        expect(page).to have_content("Works")
      end
    end
  end

  describe 'deleting a publication listing', type: :feature do
    let!(:publication_listing) { FactoryBot.create :publication_listing }
    let!(:work) { FactoryBot.create :work, publication_listing: publication_listing }
    let!(:author) { FactoryBot.create :author, work: work }

    it 'clicks link to delete publication listing' do
      visit publication_listings_path
      expect{ click_link '[Delete]' }.to change{ PublicationListing.count }.by -1
      expect(page).to have_current_path(publication_listings_path)
    end
  end
end
