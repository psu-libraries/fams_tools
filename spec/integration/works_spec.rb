require 'rails_helper'

RSpec.describe 'Works page', type: :feature do
  let!(:faculty) { FactoryBot.create(:faculty) }
  let!(:publication_listing) { FactoryBot.create(:publication_listing) }
  let!(:work) { FactoryBot.create(:work, publication_listing:) }
  let!(:author) { FactoryBot.create(:author, work:) }
  let!(:editor) { FactoryBot.create(:editor, work:) }

  describe '#show' do
    it 'displays works information' do
      visit "publication_listings/#{publication_listing.id}/works"
      expect(page).to have_content(publication_listing.name)
      expect(page).to have_content('Username')
      expect(page).to have_content('Container')
      expect(page).to have_xpath("//input[@value='#{work.username}']")
      expect(page).to have_xpath("//input[@value='#{work.authors.first.f_name}']")
      expect(page).to have_xpath("//input[@value='#{work.editors.first.f_name}']")
      expect(page).to have_content(work.title)
      # .squish will reduce the string to how it will display on page w/ whitespace reduced to single space
      expect(page).to have_content(work.citation.squish)
      expect(page).to have_link('Add Author')
      expect(page).to have_link('Add Editor')
      expect(page).to have_xpath("//i[@class='fa remove-nested fa-close']")
      expect(page).to have_button('Update Works')
    end

    it 'downloads csv' do
      visit "publication_listings/#{publication_listing.id}/works"
      click_on 'Download as csv'
      header = page.response_headers['Content-Disposition']
      expect(header).to match(/^attachment/)
    end

    # TODO: rubyzip is not compatible with ruby 3.4 at this time, causing xlsx download to fail. Sticking to csv download only until this is resolved
    xit 'downloads xlsx' do
      visit "publication_listings/#{publication_listing.id}/works"
      click_on 'Download as xlsx'
      header = page.response_headers['Content-Disposition']
      expect(header).to match(/^attachment/)
    end
  end
end
