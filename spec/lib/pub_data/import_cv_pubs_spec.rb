require 'rails_helper'
require 'pub_data/import_cv_pubs'

RSpec.describe ImportCVPubs do

  describe "#import_cv_pubs_data" do
    let(:importer) { ImportCVPubs.new("spec/fixtures/cv_pub.csv") }
    it "should parse data from csv and import to database" do
      expect(importer.import_cv_pubs_data).to change{ Publication.count }.by 2
    end
  end
end
