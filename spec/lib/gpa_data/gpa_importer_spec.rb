require 'rails_helper'
require 'gpa_data/import_gpa_data'

RSpec.describe ImportGpaData do
  let(:gpa_parser_obj) { ImportGpaData.new 'spec/fixtures/gpa_data.xlsx' }

  before do
    FactoryBot.create :faculty, access_id: 'abc123'
    FactoryBot.create :faculty, access_id: 'def456'
  end

  describe "#import" do
    it "imports data from xlsx" do
      gpa_parser_obj.import
    end
  end
end