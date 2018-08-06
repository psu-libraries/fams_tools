require 'rails_helper'
require 'spreadsheet'
require 'osp_data/osp_parser'

RSpec.describe OspParser do
  
  headers =  {"A1" => 'ospkey', "B1" => 'ordernumber', "C1" => 'title', "D1" => 'sponsor', "E1" => 'sponsortype', "F1" => 'parentsponsor', 
              "G1" => 'accessid', "H1" => 'department', "I1" => 'role', "J1" => 'pctcredit', "K1" => 'status', "L1" => 'submitted', "M1" => 'awarded', 
              "N1" => 'requested', "O1" => 'funded', "P1" => 'totalanticipated', "Q1" => 'startdate', "R1" => 'enddate', "S1" => 'totalstartdate',
              "T1" => 'totalenddate', "U1" => 'grantcontract', "V1" => 'baseagreement', "W1" => 'agreementtype', "X1" => 'agreement', "Y1" => 'notfunded'}

  let(:data_book1) do
    data_arr = []
    data_arr << headers 
    data_arr << {"A2" => 1, "B2" => 1, "C2" => 'X', "D2" => 'X', "E2" => 'X', "F2" => 'X',
                 "G2" => 'abc123', "H2" => 'X', "I2" => 'Co-PI', "J2" => 1, "K2" => 'Awarded', "L2" => '/', "M2" => '/  /',
                 "N2" => 1, "O2" => 1, "P2" => 1, "Q2" => 'Sun, 01 Jan 2017', "R2" => 'Wed, 12 Dec 2018', "S2" => 'X',
                 "T2" => 'X', "U2" => nil, "V2" => 'X', "W2" => 'X', "X2" => 'X', "Y2" => 'Sun, 01 Feb 2015'}
    data_arr << {"A3" => 1, "B3" => 1, "C3" => 'X', "D3" => 'X', "E3" => 'X', "F3" => 'X',
                 "G3" => 'Sun, 01 Mar 1926', "H3" => 'X', "I3" => 'Faculty', "J3" => 1, "K3" => 'Pending Proposal', "L3" => 'X', "M3" => 'X',
                 "N3" => 1, "O3" => 1, "P3" => 1, "Q3" => 'X', "R3" => 'X', "S3" => 'X',
                 "T3" => 'X', "U3" => 'Grant', "V3" => 'X', "W3" => 'X', "X3" => 'X', "Y3" => '/  /'}
    data_arr << {"A4" => 1, "B4" => 1, "C4" => 'X', "D4" => 'X', "E4" => 'X', "F4" => 'X',
                 "G4" => 'Tue, 02 Jan 2018', "H4" => 'X', "I4" => 'Post Doctoral', "J4" => 1, "K4" => 'Awarded', "L4" => 'X', "M4" => 'X',
                 "N4" => 1, "O4" => 1, "P4" => 1, "Q4" => 'Sun, 01 Jan 2017', "R4" => 'Wed, 12 Dec 2018', "S4" => 'X',
                 "T4" => 'X', "U4" => 'Grant', "V4" => 'X', "W4" => 'X', "X4" => 'X', "Y4" => '/  /'}
    data_arr << {"A5" => 1, "B5" => 1, "C5" => 'X', "D5" => 'X', "E5" => 'X', "F5" => 'X',
                 "G5" => 'Tue, 02 Jan 2018', "H5" => 'X', "I5" => 'unknown', "J5" => 1, "K5" => 'Pending Award', "L5" => 'X', "M5" => 'X',
                 "N5" => 1, "O5" => 1, "P5" => 1, "Q1" => 'Sun, 01 Jan 2017', "R5" => 'Wed, 12 Dec 2018', "S5" => 'X',
                 "T5" => 'X', "U5" => 'Grant', "V5" => 'X', "W5" => 'X', "X5" => 'X', "Y5" => '/  /'}
    data_arr
  end

  let(:data_book2) do
    data_arr = []
    data_arr << headers
    data_arr << {"A2" => 1, "B2" => 1, "C2" => 'X', "D2" => 'X', "E2" => 'X', "F2" => 'X', "G2" => 'X', "H2" => 'X', "I2" => 'X', "J2" => 1, "K2" => 'X', "L2" => '2001-01-01',
                "M2" => 'X', "N2" => 1, "O2" => 1, "P2" => 1, "Q2" => 'X', "R2" => 'X', "S2" => 'X', "T2" => 'X', "U2" => 'X', "V2" => 'X', "W2" => 'X', "X2" => 'X'}    
    data_arr << {"A3" => 1, "B3" => 1, "C3" => 'X', "D3" => 'X', "E3" => 'X', "F3" => 'X', "G3" => 'X', "H3" => 'X', "I3" => 'X', "J3" => 1, "K3" => 'X', "L3" => '2013-02-01',
                "M3" => 'X', "N3" => 1, "O3" => 1, "P3" => 1, "Q3" => 'X', "R3" => 'X', "S3" => 'X', "T3" => 'X', "U3" => 'X', "V3" => 'X', "W3" => 'X', "X3" => 'X'}
    data_arr << {"A4" => 1, "B4" => 1, "C4" => 'X', "D4" => 'X', "E4" => 'X', "F4" => 'X', "G4" => 'X', "H4" => 'X', "I4" => 'X', "J4" => 1, "K4" => 'X', "L4" => '2020-03-01',
                 "M4" => 'X', "N4" => 1, "O4" => 1, "P4" => 1, "Q4" => 'X', "R4" => 'X', "S4" => 'X', "T4" => 'X', "U4" => 'X', "V4" => 'X', "W4" => 'X', "X4" => 'X'}
    data_arr << {"A5" => 1, "B5" => 1, "C5" => 'X', "D5" => 'X', "E5" => 'X', "F5" => 'X', "G5" => 'X', "H5" => 'X', "I5" => 'X', "J5" => 1, "K5" => 'X', "L5" => '1989-04-01',
                "M5" => 'X', "N5" => 1, "O5" => 1, "P5" => 1, "Q5" => 'X', "R5" => 'X', "S5" => 'X', "T5" => 'X', "U5" => 'X', "V5" => 'X', "W5" => 'X', "X5" => 'X'}
    data_arr
  end

  let(:data_book3) do
    data_arr = []
    data_arr << headers
    data_arr << {"A2" => 1, "B2" => 1, "C2" => 'X', "D2" => 'X', "E2" => 'X', "F2" => 'X', "G2" => 'zzz999', "H2" => 'X', "I2" => 'X', "J2" => 1,
                 "K2" => 'X', "L2" => 'X', "M2" => 'X', "N2" => 1, "O2" => 1, "P2" => 1, "Q2" => 'X', "R2" => 'X', "S2" => 'X', "T2" => 'X', "U2" => 'X', "V2" => 'X', "W2" => 'X', "X2" => 'X'}    
    data_arr << {"A3" => 1, "B3" => 1, "C3" => 'X', "D3" => 'X', "E3" => 'X', "F3" => 'X', "G3" => 'xxx111', "H3" => 'X', "I3" => 'X', "J3" => 1,
                "K3" => 'X', "L3" => 'X', "M3" => 'X', "N3" => 1, "O3" => 1, "P3" => 1, "Q3" => 'X', "R3" => 'X', "S3" => 'X', "T3" => 'X', "U3" => 'X', "V3" => 'X', "W3" => 'X', "X3" => 'X'}
    data_arr
  end

  let(:data_book4) do
    data_arr = []
    data_arr << headers
    data_arr << {"A2" => 1, "B2" => 1, "C2" => 'X', "D2" => 'X', "E2" => 'X', "F2" => 'X', "G2" => 'X', "H2" => 'X', "I2" => 'X', "J2" => 1,
                "K2" => 'Purged', "L2" => 'X', "M2" => 'X', "N2" => 1, "O2" => 1, "P2" => 1, "Q2" => 'X', "R2" => 'X', "S2" => 'X', "T2" => 'X', "U2" => 'X', "V2" => 'X', "W2" => 'X', "X2" => 'X'} 
    data_arr << {"A3" => 1, "B3" => 1, "C3" => 'X', "D3" => 'X', "E3" => 'X', "F3" => 'X', "G3" => 'X', "H3" => 'X', "I3" => 'X', "J3" => 1,
                "K3" => 'Awarded', "L3" => 'X', "M3" => 'X', "N3" => 1, "O3" => 1, "P3" => 1, "Q3" => 'X', "R3" => 'X', "S3" => 'X', "T3" => 'X', "U3" => 'X', "V3" => 'X', "W3" => 'X', "X3" => 'X'}
    data_arr << {"A4" => 1, "B4" => 1, "C4" => 'X', "D4" => 'X', "E4" => 'X', "F4" => 'X', "G4" => 'X', "H4" => 'X', "I4" => 'X', "J4" => 1,
                "K4" => 'Withdrawn', "L4" => 'X', "M4" => 'X', "N4" => 1, "O4" => 1, "P4" => 1, "Q4" => 'X', "R4" => 'X', "S4" => 'X', "T4" => 'X', "U4" => 'X', "V4" => 'X', "W4" => 'X', "X4" => 'X'}
    data_arr
  end

  before(:each) do
    Faculty.create(access_id: 'zzz999',
                   user_id:   '123',
                   f_name:    'Bill',
                   l_name:    'Bill',
                   m_name:    'Bill')
  end


  let(:osp_parser_obj) {OspParser.new}

  describe "#format" do
    it "should convert nils to ' ' and 
        should convert calendar dates to accessids in the 'accessid' column
        should convert 'Co-PI' to 'Co-Principal Investigator', 'Faculty' to 'Core Faculty', 
        should convert 'Post Doctoral' to 'Post Doctoral Associate', and 'unknown' to 'Unknown'
        should remove time, '/', and '/ /' from date fields and 
        should convert dates to be sql friendly
        should change 'Pending Award' and 'Pending Proposal' status to 'Pending'
        should remove start and end dates for any contract that was not 'Awarded'" do
      allow(Creek::Book).to receive_message_chain(:new, :sheets, :[], :rows).and_return(data_book1)
      osp_parser_obj.format
      expect(osp_parser_obj.xlsx_hash[0]['grantcontract']).to eq('')
      expect(osp_parser_obj.xlsx_hash[1]['grantcontract']).to eq('Grant')
      expect(osp_parser_obj.xlsx_hash[0]['accessid']).to eq('abc123')
      expect(osp_parser_obj.xlsx_hash[1]['accessid']).to eq('mar26')
      expect(osp_parser_obj.xlsx_hash[2]['accessid']).to eq('jan2')
      expect(osp_parser_obj.xlsx_hash[0]['role']).to eq('Co-Principal Investigator')
      expect(osp_parser_obj.xlsx_hash[1]['role']).to eq('Core Faculty')
      expect(osp_parser_obj.xlsx_hash[2]['role']).to eq('Post Doctoral Associate')
      expect(osp_parser_obj.xlsx_hash[3]['role']).to eq('Unknown')
      expect(osp_parser_obj.xlsx_hash[0]['submitted']).to eq('')
      expect(osp_parser_obj.xlsx_hash[0]['awarded']).to eq('')
      expect(osp_parser_obj.xlsx_hash[0]['startdate']).to eq('2017-01-01')
      expect(osp_parser_obj.xlsx_hash[0]['enddate']).to eq('2018-12-12')
      expect(osp_parser_obj.xlsx_hash[3]['status']).to eq('Pending')
      expect(osp_parser_obj.xlsx_hash[1]['status']).to eq('Pending')
      expect(osp_parser_obj.xlsx_hash[2]['startdate']).to eq('2017-01-01')
      expect(osp_parser_obj.xlsx_hash[2]['enddate']).to eq('2018-12-12')
      expect(osp_parser_obj.xlsx_hash[3]['startdate']).to eq('')
      expect(osp_parser_obj.xlsx_hash[3]['enddate']).to eq('')
      expect(osp_parser_obj.xlsx_hash[0].length).to eq(25)
      expect(osp_parser_obj.xlsx_hash[1].length).to eq(25)
      expect(osp_parser_obj.xlsx_hash[0]['notfunded']).to eq('2015-02-01')
    end
  end

  context "#filter_by_date" do

    it "should remove rows with 'submitted' dates <= 2011" do
      allow(Creek::Book).to receive_message_chain(:new, :sheets, :[], :rows).and_return(data_book2)
      osp_parser_obj.filter_by_date
      expect(osp_parser_obj.xlsx_hash.count).to eq(1)
    end
  end

  context "#filter_by_user" do

    it "should remove rows that contain non-active users" do
      allow(Creek::Book).to receive_message_chain(:new, :sheets, :[], :rows).and_return(data_book3)
      osp_parser_obj.filter_by_user
      expect(osp_parser_obj.xlsx_hash.count).to eq(1)
      expect(osp_parser_obj.xlsx_hash[0]['accessid']).to eq('zzz999')
      expect(osp_parser_obj.xlsx_hash[0].length).to eq(25)
    end
  end

  context "#filter_by_status" do

    it "should remove rows with 'Purged' or 'Withdrawn' status" do
      allow(Creek::Book).to receive_message_chain(:new, :sheets, :[], :rows).and_return(data_book4)
      osp_parser_obj.filter_by_status
      expect(osp_parser_obj.xlsx_hash.count).to eq(1)
      expect(osp_parser_obj.xlsx_hash[0]['status']).to eq('Awarded')
    end
  end

end

