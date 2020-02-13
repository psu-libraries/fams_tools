require 'importers/importers_helper'

RSpec.describe OspImporter do
  
  headers =  {"A1" => 'ospkey', "B1" => 'ordernumber', "C1" => 'title', "D1" => 'sponsor', "E1" => 'sponsortype', "F1" => 'parentsponsor', 
              "G1" => 'accessid', "H1" => 'department', "I1" => 'role', "J1" => 'pctcredit', "K1" => 'status', "L1" => 'submitted', "M1" => 'awarded', 
              "N1" => 'requested', "O1" => 'funded', "P1" => 'totalanticipated', "Q1" => 'startdate', "R1" => 'enddate', "S1" => 'totalstartdate',
              "T1" => 'totalenddate', "U1" => 'grantcontract', "V1" => 'baseagreement', "W1" => 'agreementtype', "X1" => 'agreement', "Y1" => 'notfunded'}

  let(:data_book1) do
    current_year = DateTime.now.year
    data_arr = []
    data_arr << headers 
    data_arr << {"A2" => 1, "B2" => 1, "C2" => 'Title &quot; &#39;', "D2" => 'X', "E2" => 'X', "F2" => 'X',
                 "G2" => 'abc123', "H2" => 'X', "I2" => 'Co-PI', "J2" => 1, "K2" => 'Awarded', "L2" => '/', "M2" => '/  /',
                 "N2" => 2, "O2" => 1, "P2" => 1, "Q2" => 'Sun, 01 Jan 2017', "R2" => 'Wed, 12 Dec 2018', "S2" => 'X',
                 "T2" => 'X', "U2" => nil, "V2" => 'X', "W2" => 'X', "X2" => 'X', "Y2" => 'Sun, 01 Feb 2015'}
    data_arr << {"A3" => 3, "B3" => 1, "C3" => 'X', "D3" => 'X', "E3" => 'X', "F3" => 'X',
                 "G3" => 'Sun, 01 Mar 1926', "H3" => 'X', "I3" => 'Faculty', "J3" => 1, "K3" => 'Pending Proposal', "L3" => 'X', "M3" => 'X',
                 "N3" => 4, "O3" => 1, "P3" => 1, "Q3" => 'X', "R3" => 'X', "S3" => 'X',
                 "T3" => 'X', "U3" => 'Grant', "V3" => 'X', "W3" => 'X', "X3" => 'X', "Y3" => '/  /'}
    data_arr << {"A4" => 5, "B4" => 1, "C4" => 'X', "D4" => 'X', "E4" => 'X', "F4" => 'X',
                 "G4" => "Tue, 02 Jan #{current_year}", "H4" => 'X', "I4" => 'Post Doctoral', "J4" => 1, "K4" => 'Awarded', "L4" => 'X', "M4" => 'X',
                 "N4" => 6, "O4" => 1, "P4" => 1, "Q4" => 'Sun, 01 Jan 2017', "R4" => 'Wed, 12 Dec 2018', "S4" => 'X',
                 "T4" => 'X', "U4" => 'Grant', "V4" => 'X', "W4" => 'X', "X4" => 'X', "Y4" => '/  /'}
    data_arr << {"A5" => 7, "B5" => 1, "C5" => 'X', "D5" => 'X', "E5" => 'X', "F5" => 'X',
                 "G5" => 'Tue, 02 Jan 2018', "H5" => 'X', "I5" => 'unknown', "J5" => 1, "K5" => 'Pending Award', "L5" => 'X', "M5" => 'X',
                 "N5" => 8, "O5" => 1, "P5" => 1, "Q1" => 'Sun, 01 Jan 2017', "R5" => 'Wed, 12 Dec 2018', "S5" => 'X',
                 "T5" => 'X', "U5" => 'Grant', "V5" => 'X', "W5" => 'X', "X5" => 'X', "Y5" => '/  /'}
    data_arr
  end

  let(:data_book2) do
    data_arr = []
    data_arr << headers
    data_arr << {"A2" => 1, "B2" => 1, "C2" => 'X', "D2" => 'X', "E2" => 'X', "F2" => 'X', "G2" => 'X', "H2" => 'X', "I2" => 'X', "J2" => 1, "K2" => 'X', "L2" => '2001-01-01',
                "M2" => 'X', "N2" => 1, "O2" => 1, "P2" => 1, "Q2" => 'X', "R2" => 'X', "S2" => 'X', "T2" => 'X', "U2" => 'X', "V2" => 'X', "W2" => 'X', "X2" => 'X'}    
    data_arr << {"A3" => 2, "B3" => 1, "C3" => 'X', "D3" => 'X', "E3" => 'X', "F3" => 'X', "G3" => 'X', "H3" => 'X', "I3" => 'X', "J3" => 1, "K3" => 'X', "L3" => '2013-02-01',
                "M3" => 'X', "N3" => 1, "O3" => 1, "P3" => 1, "Q3" => 'X', "R3" => 'X', "S3" => 'X', "T3" => 'X', "U3" => 'X', "V3" => 'X', "W3" => 'X', "X3" => 'X'}
    data_arr << {"A4" => 3, "B4" => 1, "C4" => 'X', "D4" => 'X', "E4" => 'X', "F4" => 'X', "G4" => 'X', "H4" => 'X', "I4" => 'X', "J4" => 1, "K4" => 'X', "L4" => "#{DateTime.now.year + 1}-03-01",
                 "M4" => 'X', "N4" => 1, "O4" => 1, "P4" => 1, "Q4" => 'X', "R4" => 'X', "S4" => 'X', "T4" => 'X', "U4" => 'X', "V4" => 'X', "W4" => 'X', "X4" => 'X'}
    data_arr << {"A5" => 4, "B5" => 1, "C5" => 'X', "D5" => 'X', "E5" => 'X', "F5" => 'X', "G5" => 'X', "H5" => 'X', "I5" => 'X', "J5" => 1, "K5" => 'X', "L5" => '1989-04-01',
                "M5" => 'X', "N5" => 1, "O5" => 1, "P5" => 1, "Q5" => 'X', "R5" => 'X', "S5" => 'X', "T5" => 'X', "U5" => 'X', "V5" => 'X', "W5" => 'X', "X5" => 'X'}
    data_arr << {"A6" => 5, "B6" => 1, "C6" => 'X', "D6" => 'X', "E6" => 'X', "F6" => 'X', "G6" => 'X', "H6" => 'X', "I6" => 'X', "J6" => 1, "K6" => 'X', "L6" => '',
                 "M6" => '2013-02-01', "N6" => 1, "O6" => 1, "P6" => 1, "Q6" => 'X', "R6" => 'X', "S6" => 'X', "T6" => 'X', "U6" => 'X', "V6" => 'X', "W6" => 'X', "X6" => 'X'}
    data_arr << {"A7" => 6, "B7" => 1, "C7" => 'X', "D7" => 'X', "E7" => 'X', "F7" => 'X', "G7" => 'X', "H7" => 'X', "I7" => 'X', "J7" => 1, "K7" => 'X', "L7" => '',
                 "M7" => '', "N7" => 1, "O7" => 1, "P7" => 1, "Q7" => 'X', "R7" => 'X', "S7" => 'X', "T7" => 'X', "U7" => 'X', "V7" => 'X', "W7" => 'X', "X7" => 'X'}
    data_arr
  end

  let(:data_book3) do
    data_arr = []
    data_arr << headers
    data_arr << {"A2" => 1, "B2" => 1, "C2" => 'X', "D2" => 'X', "E2" => 'X', "F2" => 'X', "G2" => 'zzz999', "H2" => 'X', "I2" => 'X', "J2" => 1,
                 "K2" => 'X', "L2" => 'X', "M2" => 'X', "N2" => 1, "O2" => 1, "P2" => 1, "Q2" => 'X', "R2" => 'X', "S2" => 'X', "T2" => 'X', "U2" => 'X', "V2" => 'X', "W2" => 'X', "X2" => 'X'}    
    data_arr << {"A3" => 2, "B3" => 1, "C3" => 'X', "D3" => 'X', "E3" => 'X', "F3" => 'X', "G3" => 'xxx111', "H3" => 'X', "I3" => 'X', "J3" => 1,
                "K3" => 'X', "L3" => 'X', "M3" => 'X', "N3" => 1, "O3" => 1, "P3" => 1, "Q3" => 'X', "R3" => 'X', "S3" => 'X', "T3" => 'X', "U3" => 'X', "V3" => 'X', "W3" => 'X', "X3" => 'X'}
    data_arr
  end

  let(:data_book4) do
    data_arr = []
    data_arr << headers
    data_arr << {"A2" => 1, "B2" => 1, "C2" => 'X', "D2" => 'X', "E2" => 'X', "F2" => 'X', "G2" => 'X', "H2" => 'X', "I2" => 'X', "J2" => 1,
                "K2" => 'Purged', "L2" => 'X', "M2" => 'X', "N2" => 1, "O2" => 1, "P2" => 1, "Q2" => 'X', "R2" => 'X', "S2" => 'X', "T2" => 'X', "U2" => 'X', "V2" => 'X', "W2" => 'X', "X2" => 'X'} 
    data_arr << {"A3" => 2, "B3" => 1, "C3" => 'X', "D3" => 'X', "E3" => 'X', "F3" => 'X', "G3" => 'X', "H3" => 'X', "I3" => 'X', "J3" => 1,
                "K3" => 'Awarded', "L3" => 'X', "M3" => 'X', "N3" => 1, "O3" => 1, "P3" => 1, "Q3" => 'X', "R3" => 'X', "S3" => 'X', "T3" => 'X', "U3" => 'X', "V3" => 'X', "W3" => 'X', "X3" => 'X'}
    data_arr << {"A4" => 3, "B4" => 1, "C4" => 'X', "D4" => 'X', "E4" => 'X', "F4" => 'X', "G4" => 'X', "H4" => 'X', "I4" => 'X', "J4" => 1,
                "K4" => 'Withdrawn', "L4" => 'X', "M4" => 'X', "N4" => 1, "O4" => 1, "P4" => 1, "Q4" => 'X', "R4" => 'X', "S4" => 'X', "T4" => 'X', "U4" => 'X', "V4" => 'X', "W4" => 'X', "X4" => 'X'}
    data_arr << {"A5" => 123456, "B5" => 1, "C5" => 'X', "D5" => 'X', "E5" => 'X', "F5" => 'X', "G5" => 'X', "H5" => 'X', "I5" => 'X', "J5" => 1,
                "K5" => 'Withdrawn', "L5" => 'X', "M5" => 'X', "N5" => 1, "O5" => 1, "P5" => 1, "Q5" => 'X', "R5" => 'X', "S5" => 'X', "T5" => 'X', "U5" => 'X', "V5" => 'X', "W5" => 'X', "X5" => 'X'}
    data_arr << {"A6" => 193848, "B6" => 1, "C6" => 'X', "D6" => 'X', "E6" => 'X', "F6" => 'X', "G6" => 'X', "H6" => 'X', "I6" => 'X', "J6" => 1,
                "K6" => 'Purged', "L6" => 'X', "M6" => 'X', "N6" => 1, "O6" => 1, "P6" => 1, "Q6" => 'X', "R6" => 'X', "S6" => 'X', "T6" => 'X', "U6" => 'X', "V6" => 'X', "W6" => 'X', "X6" => 'X'}
    data_arr
  end

  let(:data_book5) do
    data_arr = []
    arr_of_hashes = []
    keys = headers.values
    data_arr << headers.values
    data_arr << [1234, 1, 'Cool Title', 'Cool Sponsor', 'Federal Agencies', 'X',
                 'abc123', 'Department', 'Co-PI', 50, 'Pending', '2013-04-05',
                 '/  /', 1, 1, 1, '', '', '', '', '', '', '', '', '2015-02-01']
    data_arr << [4321, 1, 'Cooler Title', 'Cool Sponsor', 'Federal Agencies', 'X',
                 'abc123', 'Department', 'Co-PI', 50, 'Pending', '2013-04-05',
                 '/  /', 1, 1, 1, '', '', '', '', '', '', '', '', '']
    data_arr << [1234, 1, 'Cool Title', 'Cool Sponsor', 'Federal Agencies', 'X',
                 'xyz123', 'Department', 'Co-PI', 50, 'Pending', '2013-04-05',
                 '/  /', 1, 1, 1, '', '', '', '', '', '', '', '', '2015-02-01']
    data_arr << [1221, 1, 'Coolest Title', 'Not as Cool Sponsor', 'Universities and Colleges', 'X',
                 'xyz123', 'Department', 'Co-PI', 50, 'Pending', '2013-04-05',
                 '/  /', 1, 1, 1, '', '', '', '', '', '', '', '', '']
    data_arr.each {|a| arr_of_hashes << Hash[ keys.zip(a) ] }
    arr_of_hashes
  end

  let(:fake_backup) do
    data_arr = []
    data_arr << ['OSPKEY', 'STATUS']
    data_arr << [123456, 'Pending']
    data_arr << [193848, 'Not Funded']
  end

  before(:each) do
    Faculty.create(access_id: 'zzz999',
                   user_id:   '123',
                   f_name:    'Bill',
                   l_name:    'Bill',
                   m_name:    'Bill')
    Faculty.create(access_id: 'xyz123',
                   user_id:   '54321',
                   f_name:    'Xylophone',
                   l_name:    'Zebra',
                   m_name:    'Yawn')
    FactoryBot.create(:faculty, access_id: 'abc123')
    FactoryBot.create(:faculty, access_id: 'mar26')
    FactoryBot.create(:faculty, access_id: 'jan2')
    FactoryBot.create(:faculty, access_id: 'jan18')
  end


  let(:osp_parser_obj) {OspImporter.new}

  describe "#format_and_populate" do
    it "should convert nils to ' ' and 
        should convert calendar dates to accessids in the 'accessid' column
        should convert 'Co-PI' to 'Co-Principal Investigator', 'Faculty' to 'Core Faculty', 
        should convert 'Post Doctoral' to 'Post Doctoral Associate', and 'unknown' to 'Unknown'
        should remove time, '/', and '/ /' from date fields and 
        should convert dates to be sql friendly
        should change 'Pending Award' and 'Pending Proposal' status to 'Pending'
        should remove start and end dates for any contract that was not 'Awarded'" do
      allow(Creek::Book).to receive_message_chain(:new, :sheets, :[], :rows).and_return(data_book1)
      allow(CSV).to receive(:foreach).and_yield(fake_backup[0]).and_yield(fake_backup[1]).and_yield(fake_backup[2])
      allow_any_instance_of(OspImporter).to receive(:is_user).and_return(true)
      allow_any_instance_of(OspImporter).to receive(:is_good_date).and_return(true)
      allow_any_instance_of(OspImporter).to receive(:is_proper_status).and_return(true)
      osp_parser_obj.format_and_populate
      expect(Contract.first.grant_contract).to eq('')
      expect(Contract.first.title).to match(/Title " '/)
      expect(Contract.second.grant_contract).to eq('Grant')
      expect(Contract.first.contract_faculty_links.first.faculty.access_id).to eq('abc123')
      expect(Contract.second.contract_faculty_links.first.faculty.access_id).to eq('mar26')
      expect(Contract.third.contract_faculty_links.first.faculty.access_id).to eq('jan2')
      expect(Contract.first.contract_faculty_links.first.role).to eq('Co-Principal Investigator')
      expect(Contract.second.contract_faculty_links.first.role).to eq('Core Faculty')
      expect(Contract.third.contract_faculty_links.first.role).to eq('Post Doctoral Associate')
      expect(Contract.fourth.contract_faculty_links.first.role).to eq('Unknown')
      expect(Contract.first.submitted).to eq(nil)
      expect(Contract.first.awarded).to eq(nil)
      expect(Contract.first.start_date).to eq(Date.parse('Sun, 01 Jan 2017'))
      expect(Contract.first.end_date).to eq(Date.parse('Wed, 12 Dec 2018'))
      expect(Contract.fourth.status).to eq('Pending')
      expect(Contract.second.status).to eq('Pending')
      expect(Contract.third.start_date).to eq(Date.parse('Sun, 01 Jan 2017'))
      expect(Contract.third.end_date).to eq(Date.parse('Wed, 12 Dec 2018'))
      expect(Contract.fourth.start_date).to eq(nil)
      expect(Contract.fourth.end_date).to eq(nil)
      expect(Contract.first.notfunded).to eq(Date.parse('Sun, 01 Feb 2015'))
    end
  end

  context "#is_good_date" do

    it "should remove rows with 'submitted' dates <= 2011" do
      allow(Creek::Book).to receive_message_chain(:new, :sheets, :[], :rows).and_return(data_book2)
      allow(CSV).to receive(:foreach).and_yield(fake_backup[0]).and_yield(fake_backup[1]).and_yield(fake_backup[2])
      allow_any_instance_of(OspImporter).to receive(:is_proper_status).and_return(true)
      allow_any_instance_of(OspImporter).to receive(:is_user).and_return(true)
      osp_parser_obj.format_and_populate
      expect(Contract.count).to eq(2)
    end
  end

  context "#is_user" do

    it "should remove rows that contain non-active users" do
      allow(Creek::Book).to receive_message_chain(:new, :sheets, :[], :rows).and_return(data_book3)
      allow(CSV).to receive(:foreach).and_yield(fake_backup[0]).and_yield(fake_backup[1]).and_yield(fake_backup[2])
      allow_any_instance_of(OspImporter).to receive(:is_proper_status).and_return(true)
      allow_any_instance_of(OspImporter).to receive(:is_good_date).and_return(true)
      osp_parser_obj.format_and_populate
      expect(Contract.count).to eq(1)
      expect(Contract.first.contract_faculty_links.first.faculty.access_id).to eq('zzz999')
    end
  end

  context "#filter_by_status" do

    it "should remove rows with 'Purged' or 'Withdrawn' status" do
      allow(Creek::Book).to receive_message_chain(:new, :sheets, :[], :rows).and_return(data_book4)
      allow(CSV).to receive(:foreach).and_yield(fake_backup[0]).and_yield(fake_backup[1]).and_yield(fake_backup[2])
      allow_any_instance_of(OspImporter).to receive(:is_good_date).and_return(true)
      allow_any_instance_of(OspImporter).to receive(:is_user).and_return(true)
      osp_parser_obj.format_and_populate
      expect(Contract.count).to eq(3)
      expect(Contract.first.status).to eq('Awarded')
      expect(Contract.second.status).to eq('Withdrawn')
      expect(Contract.third.status).to eq('Purged')
    end
  end

  context '#populate_db_with_row' do
    it 'should populate the database with osp data' do
      allow(Creek::Book).to receive_message_chain(:new, :sheets, :[], :rows).and_return(data_book5)
      allow(CSV).to receive(:foreach).and_yield(fake_backup[0]).and_yield(fake_backup[1]).and_yield(fake_backup[2])
      allow_any_instance_of(OspImporter).to receive(:is_user).and_return(true)
      allow_any_instance_of(OspImporter).to receive(:is_good_date).and_return(true)
      allow_any_instance_of(OspImporter).to receive(:is_proper_status).and_return(true)
      osp_parser_obj.format_and_populate
      expect(Sponsor.all.count).to eq(2)
      expect(Contract.all.count).to eq(3)
      expect(Faculty.all.count).to eq(6)
      expect(ContractFacultyLink.all.count).to eq(4)
      expect(Faculty.find_by(:access_id => 'abc123').contract_faculty_links.all.count).to eq(2)
      expect(Faculty.find_by(:access_id => 'abc123').contract_faculty_links.first.contract.sponsor.sponsor_name).to eq('Cool Sponsor')
      expect(Contract.find_by(:osp_key => 1234).notfunded).to eq(Date.parse('Sun, 01 Feb 2015'))
    end
  end
end

