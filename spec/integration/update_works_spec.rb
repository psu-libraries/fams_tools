require 'rails_helper'

RSpec.describe 'Updating works', type: :feature, js: true do

  let!(:faculty) { FactoryBot.create :faculty }
  let!(:publication_listing) { FactoryBot.create :publication_listing }
  let!(:work) { FactoryBot.create :work, publication_listing: publication_listing }
  let!(:author) { FactoryBot.create :author, work: work }
  let!(:editor) { FactoryBot.create :editor, work: work }

  describe 'modifying and updating data' do
    it 'updates the data in db' do
      visit "publication_listings/#{publication_listing.id}/works"
      click_link "Add Author"
      author_fields = all("input[name^='publication_listing[works_attributes][0][authors_attributes]']")
      author_fields[3].set('Test')
      author_fields[4].set('T.')
      author_fields[5].set('Tester')
      find("#publication_listing_works_attributes_0_title").set('New Title')
      find("#publication_listing_works_attributes_0_date").set('September 23-30, 2010')
      all("i[class='fa remove-nested fa-close']").last.trigger('click')
      find("#publication_listing_works_attributes_0_isbn").set('1234567890')
      click_button 'Update Works'
      sleep 1
      expect(Author.count).to eq 2
      expect(Author.second.m_name).to eq 'T.'
      expect(Editor.count).to eq 0
      expect(Work.find(work.id).title).to eq 'New Title'
      expect(Work.find(work.id).date).to eq 'September 23-30, 2010'
      expect(Work.find(work.id).isbn).to eq '1234567890'
    end
  end
end
