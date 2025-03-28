require 'importers/importers_helper'

RSpec.describe ComData::ComEffortPopulateDb do
  headers = %w[FACULTY_USERNAME FACULTY_NAME COURSE COURSE_YEAR EVENT_TYPE EVENT
               EVENT_DATE UME_CALCULATED_TEACHING_WHILE_NON_BILLING_EFFORT__HRS_]

  let(:fake_sheet) do
    data_arr = []
    keys = headers
    data_arr << ['lskywalker', 'Skywalker Luke', 'the Force',  '1976-1977', 'Lecture',
                 'FTF REQ Various Rooms 10-12 PBL - EndoRepro PBL 1402 - Thyroid', '5/25/1977 10:00', 2.5]
    data_arr << ['lskywalker', 'Skywalker Luke', 'the Force',  '1976-1977', 'Lecture',
                 'FTF REQ Various Rooms 10-12 PBL - EndoRepro PBL 1402 - Thyroid', '5/25/1977 1:00', 4]
    data_arr << ['hgranger', 'Granger Hermione', 'Potions', '1997-1998', 'Sm Grp Facilitation',
                 'FTF REQ Various Rooms 10-12 PBL - EndoRepro PBL 1402 - Thyroid', '6/26/1997 9:45', 7]
    data_arr << ['hgranger', 'Granger Hermione', 'Dark Arts', '2001-2002', 'Sm Grp Facilitation',
                 'FTF REQ Various Rooms 10-12 PBL - EndoRepro PBL 1402 - Thyroid', '11/1/2001 12:00', 8]
    data_arr.map { |a| keys.zip(a).to_h }
  end

  let(:com_effort_populate_db_obj) { ComData::ComEffortPopulateDb.allocate }

  let!(:faculty1) do
    Faculty.create(access_id: 'xyz123',
                   user_id: '923456',
                   f_name: 'Hermione',
                   l_name: 'Granger',
                   m_name: 'Not Bill',
                   com_id: 'hgranger')
  end

  let!(:faculty2) do
    Faculty.create(access_id: 'abc123',
                   user_id: '123456',
                   f_name: 'Luke',
                   l_name: 'Skywalker',
                   m_name: 'Bill',
                   com_id: 'lskywalker')
  end

  describe '#populate' do
    it 'populates the database with com effort data' do
      com_effort_populate_db_obj.com_parser = ComData::ComParser.allocate
      com_effort_populate_db_obj.com_parser.csv_hash = fake_sheet
      com_effort_populate_db_obj.populate
      expect(ComEffort.count).to eq(3)
      expect(ComEffort.where(com_id: 'hgranger').count).to eq(2)
      expect(ComEffort.find_by(com_id: 'hgranger').course).to eq('Dark Arts')
      expect(ComEffort.find_by(com_id: 'hgranger').course_year).to eq('2001-2002')
      expect(ComEffort.find_by(com_id: 'hgranger').hours).to eq(8)
      expect(ComEffort.find_by(com_id: 'hgranger').event_type).to eq('Sm Grp Facilitation')
      expect(ComEffort.find_by(com_id: 'hgranger').event).to eq('FTF REQ Various Rooms 10-12 PBL - EndoRepro PBL 1402 - Thyroid')
      expect(ComEffort.find_by(com_id: 'lskywalker').hours).to eq(6.5)
      expect(ComEffort.find_by(com_id: 'lskywalker').event_type).to eq('Lecture')
      expect(ComEffort.find_by(com_id: 'lskywalker').faculty).to eq(faculty2)
    end
  end
end
