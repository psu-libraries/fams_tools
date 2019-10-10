require 'rails_helper'
require 'gpa_data/gpa_xml_builder'

RSpec.describe GpaXmlBuilder do

  let!(:faculty) { FactoryBot.create :faculty }
  let!(:gpa) { FactoryBot.create :gpa, faculty: faculty }
  let(:gpa_xml_builder) { described_class.new }

  describe "#batched_gpa_xmls" do
    it "should return an array of gpa data xmls" do
      puts gpa_xml_builder.batched_xmls
    end
  end
end