require 'rails_helper'
require 'pub_data/import_cv_pubs'

RSpec.describe ImportCVPubs do

  before do
    Faculty.create( user_id: 123456 )
  end

  describe "#import_cv_pubs_data" do

    let(:importer) { ImportCVPubs.new("spec/fixtures/cv_pub.csv") }

    it "should parse data from csv and import to database" do
      expect{importer.import_cv_pubs_data}.to change{ Publication.count }.by 2
      expect(ExternalAuthor.count).to eq 2
      
      p1 = Publication.first
      p2 = Publication.second

      expect(p1.title).to eq("Test Title 1")
    end
  end
end
