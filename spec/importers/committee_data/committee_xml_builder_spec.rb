require 'rails_helper'

RSpec.describe CommitteeData::CommitteeXmlBuilder do
  describe '#xmls_enumerator' do
    let!(:faculty) do
      Faculty.create!(access_id: 'test123')
    end

    let!(:committee) do
      Committee.create!(
        faculty: faculty,
        student_fname: 'Peter',
        student_lname: 'Parker',
        role: 'friendly neighbourhood spiderman',
        thesis_title: 'cook Green Goblin',
        degree_type: 'full time hero'
      )
    end

    it 'builds DSL XML from committee records' do
      builder = described_class.new
      xml = builder.xmls_enumerator.first

      doc = Nokogiri::XML(xml)

      record = doc.at_xpath('//Record')
      expect(record['username']).to eq('test123')

      expect(doc.at_xpath('//DSL/ROLE').text).to eq('Mentor')

      student = doc.at_xpath('//DSL_STUDENT')
      expect(student.at_xpath('FNAME').text).to eq('Test')
      expect(student.at_xpath('LNAME').text).to eq('User')
      expect(student.at_xpath('DEG').text).to eq('PhD')
      expect(student.at_xpath('TITLE').text).to eq('Test Title')
    end
  end
end
