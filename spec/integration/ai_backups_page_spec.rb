require 'rails_helper'

RSpec.describe AiBackupsListingController do
  let(:filepath) {File.join('public', 'psu', 'test.zip')}

  before do
    File.open(filepath, "wb") { |f| f.write('foo') } unless File.exist? filepath
  end

  after do
    File.delete filepath if File.exist? filepath
  end

  describe "#index" do
    it 'lists backup', type: :feature do
      visit ai_backups_listing_path
      expect(page).to have_content 'test.zip'
    end
  end
end
