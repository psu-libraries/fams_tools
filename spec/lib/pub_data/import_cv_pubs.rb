require 'rails_helper'
require 'pub_data/import_cv_pubs'

RSpec.describe ImportCVPubs do

  describe "#import_cv_pubs_data" do
    let(:importer) { ImportCVPubs.new("spec/fixtures/cv_pub.csv") }
    it "should parse data from csv and import to database" do
      importer.import_cv_pubs_data
    end
  end
end
