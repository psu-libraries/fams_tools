require 'rails_helper'

RSpec.describe 'Works page', type: :feature do

  let!(:faculty) { FactoryBot.create :faculty }
  let!(:publication_listing) { FactoryBot.create :publication_listing }
  let!(:work) { FactoryBot.create :work, publication_listing: publication_listing }

  describe "#show" do
    it 'displays works information' do
      visit "publication_listings/#{publication_listing.id}/works"
      expect(page).to have_content(publication_listing.name)
      expect(page).to have_content('username')
      expect(page).to have_content('container')
      expect(page).to have_content('test123')
      expect(page).to have_content('Test')
      expect(page).to have_content('Jim')
    end

    it 'downloads csv' do
      visit "publication_listings/#{publication_listing.id}/works"
      click_on 'Download as csv'
      header = page.response_headers['Content-Disposition']
      expect(header).to match /^attachment/
    end

    it 'downloads bibtex' do
      visit "publication_listings/#{publication_listing.id}/works"
      click_on 'Download as bibtex'
      header = page.response_headers['Content-Disposition']
      expect(header).to match /^attachment/
    end

    it 'downloads xlsx' do
      visit "publication_listings/#{publication_listing.id}/works"
      click_on 'Download as xlsx'
      header = page.response_headers['Content-Disposition']
      expect(header).to match /^attachment/
    end
  end
end
