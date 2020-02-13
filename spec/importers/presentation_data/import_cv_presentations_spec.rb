require 'importers/importers_helper'

RSpec.describe ImportCVPresentations do

  before do
    Faculty.create( user_id: 123456 )
  end

  describe "#import_cv_presentations_data" do

    let(:importer) { ImportCVPresentations.new("spec/fixtures/cv_presentation.csv") }

    it "should parse data from csv and import to database" do
      expect{importer.import_cv_presentations_data}.to change{ Presentation.count }.by 2
      
      p1 = Presentation.first
      p2 = Presentation.second

      expect(p1.title).to eq("Presentation 1")
      expect(p1.dty_date).to eq("2016")
      expect(p1.name).to eq("Conference 1")
      expect(p1.org).to eq("Penn State")
      expect(p1.location).to eq("State College, PA")
      expect(p1.presentation_contributors.count).to eq(2)
      expect(p1.presentation_contributors.first.l_name).to eq("Bob")
      expect(p1.presentation_contributors.first.f_name).to eq("B.")
      expect(p1.presentation_contributors.first.m_name).to eq("B.")
      expect(p1.presentation_contributors.second.l_name).to eq("Reynolds")
      expect(p1.presentation_contributors.second.f_name).to eq("F.")
      expect(p1.presentation_contributors.second.m_name).to eq("W.")

      expect(p2.title).to eq("Presentation 2")
      expect(p2.dty_date).to eq("2009")
      expect(p2.name).to eq("Conference 2")
      expect(p2.org).to eq("Penn State")
      expect(p2.location).to eq("State College, PA")
      expect(p2.presentation_contributors.count).to eq(1)
      expect(p2.presentation_contributors.first.l_name).to eq("Bob")
      expect(p2.presentation_contributors.first.f_name).to eq("B.")
      expect(p2.presentation_contributors.first.m_name).to eq("B.")
    end
  end
end

