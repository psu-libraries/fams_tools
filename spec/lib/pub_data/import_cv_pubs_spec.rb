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
      expect(p1.volume).to eq(1)
      expect(p1.edition).to eq(2)
      expect(p1.page_range).to eq("30-40")
      expect(p1.dty).to eq(2012)
      expect(p1.journal_title).to eq("Test Journal 1")
      expect(p1.web_address).to eq(nil)
      expect(p1.editors).to eq(nil)
      expect(p1.institution).to eq("Penn State")
      expect(p1.isbnissn).to eq(nil)
      expect(p1.pubctyst).to eq("State College, PA")
      expect(p1.external_authors.count).to eq(1)
      expect(p1.external_authors.first.l_name).to eq("Bob")
      expect(p1.external_authors.first.f_name).to eq("B.")
      expect(p1.external_authors.first.m_name).to eq("B.")

      expect(p2.title).to eq("Test Title 2")
      expect(p2.volume).to eq(2)
      expect(p2.edition).to eq(3)
      expect(p2.page_range).to eq("40-50")
      expect(p2.dty).to eq(2013)
      expect(p2.journal_title).to eq("Test Journal 2")
      expect(p2.web_address).to eq(nil)
      expect(p2.editors).to eq(nil)
      expect(p2.institution).to eq("Penn State")
      expect(p2.isbnissn).to eq(nil)
      expect(p2.external_authors.count).to eq(1)
      expect(p2.external_authors.first.l_name).to eq("Bob")
      expect(p2.external_authors.first.f_name).to eq("B.")
      expect(p2.external_authors.first.m_name).to eq("B.")
    end
  end
end
