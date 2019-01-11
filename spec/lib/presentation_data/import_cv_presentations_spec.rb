require 'rails_helper'
require 'presentation_data/import_cv_presentations'

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
    end
  end
end

