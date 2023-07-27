require 'importers/importers_helper'

RSpec.describe ComData::ComQualityPopulateDb do

  headers = ['FACULTY_USERNAME', 'FACULTY_NAME', 'COURSE', 'COURSE_YEAR', 'EVALUATION_TYPE', 'UME_AVERAGE_RATING',
  'NUMBER_OF_EVALUATIONS', 'EVALUATION_NAME']

  let(:fake_sheet) do
    data_arr = []
    arr_of_hashes = []
    keys = headers
    data_arr << ['batman', 'Wayne  Bruce', 'Endocrinology/Reproductive',  '1938-1939', 'faculty', 4.2, 1939, 'Lecture']
    data_arr << ['spiderman', 'Parker  Peter', 'Swinging',  '1962-1963', 'faculty', 5.0, 575, 'Lecture']
    data_arr << ['spiderman', 'Parker  Peter', 'Climbing',  '2023-2024', 'faculty', 5.0, 575, 'Sm Grp Facilitation']
    data_arr.each {|a| arr_of_hashes << Hash[ keys.zip(a) ] }
    arr_of_hashes
  end

  let(:com_quality_populate_db_obj) {ComData::ComQualityPopulateDb.allocate}

  let!(:faculty1) do
    Faculty.create(access_id: 'abc123',
                   user_id:   '123456',
                   f_name:    'Bruce',
                   l_name:    'Wayne',
                   m_name:    'Bill',
                   com_id:    'batman')
  end

  let!(:faculty2) do
    Faculty.create(access_id: 'xyz123',
                   user_id:   '923456',
                   f_name:    'Peter',
                   l_name:    'Parker',
                   m_name:    'Not Bill',
                   com_id:    'spiderman')
  end

  describe '#populate' do
    it 'should populate the database with com quality data' do
      com_quality_populate_db_obj.com_parser = ComData::ComParser.allocate
      com_quality_populate_db_obj.com_parser.csv_hash = fake_sheet
      com_quality_populate_db_obj.populate
      expect(ComQuality.all.count).to eq(3)
      expect(ComQuality.where(:com_id => 'spiderman').count).to eq(2)
      expect(ComQuality.find_by(:com_id => 'spiderman').course).to eq('Climbing')
      expect(ComQuality.find_by(:com_id => 'batman').event_type).to eq('Lecture')
      expect(ComQuality.find_by(:com_id => 'batman').faculty).to eq(faculty1)
    end
  end

end
