require 'rails_helper'
require 'spreadsheet'
require 'osp_format'
require 'byebug'

RSpec.describe OspFormat do

  let(:headers) {['ospkey', 'ordernumber', 'title', 'sponsor', 'sponsortype', 'parentsponsor', 
                  'accessid', 'department', 'role', 'pctcredit', 'status', 'submitted', 'awarded', 
                  'requested', 'funded', 'totalanticipated', 'startdate', 'enddate', 'totalstartdate',
                  'totalenddate', 'grantcontract', 'baseagreement', 'agreementtype', 'agreement']}      

  let(:line1) {[1, 1, 'X', 'X', 'X', 'X',
                'abc123', 'X', 'Co-PI', 1, 'Awarded', '/', '/  /',
                1, 1, 1, '1/1/17 0:00', '12/12/18 0:00', 'X',
                'X', nil, 'X', 'X', 'X']}

  let(:line2) {[1, 1, 'X', 'X', 'X', 'X',
                'Mar-26', 'X', 'Faculty', 1, 'Pending Proposal', 'X', 'X',
                1, 1, 1, 'X', 'X', 'X',
                'X', 'Grant', 'X', 'X', 'X']}

  let(:line3) {[1, 1, 'X', 'X', 'X', 'X',
                '2-Jan', 'X', 'Post Doctoral', 1, 'Awarded', 'X', 'X',
                1, 1, 1, '2017-01-01', '2018-12-12', 'X',
                'X', 'Grant', 'X', 'X', 'X']}

  let(:line4) {[1, 1, 'X', 'X', 'X', 'X',
                '2-Jan', 'X', 'unknown', 1, 'Pending Award', 'X', 'X',
                1, 1, 1, '2017-01-01', '2018-12-12', 'X',
                'X', 'Grant', 'X', 'X', 'X']}

  let(:osp_obj) {OspFormat.new([headers, line1, line2, line3, line4], book)}

  let(:book) do
    book = Spreadsheet::Workbook.new  
    sheet = book.create_worksheet
    sheet.row(1).replace []
    sheet.row(2).replace []
    sheet.row(3).replace ['Last Name', 'First Name', 'Middle Name', 'Email', 'Username', 'PSU ID #', 'Enabled?', 'Has Access to Manage Activities?', 
                          'Campus', 'Campus Name', 'College', 'College Name', 'Department', 'Division', 'Institute', 'School', 'Security']
    sheet.row(4).replace ['X', 'Bill', 'X', 'X', 'zzz999', 'X', 'Yes', 'Yes', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X']
    sheet.row(5).replace ['X', 'Jimmy', 'X', 'X', 'xxx111', 'X', 'No', 'No', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X']
    book
  end

  describe "#format" do
    it "should convert nils to ' ' and 
        should convert calendar dates to accessids in the 'accessid' column
        should convert 'Co-PI' to 'Co-Principal Investigator', 'Faculty' to 'Core Faculty', 
        should convert 'Post Doctoral' to 'Post Doctoral Associate', and 'unknown' to 'Unknown'
        should remove time, '/', and '/ /' from date fields and 
        should convert dates to be sql friendly
        should change 'Pending Award' and 'Pending Proposal' status to 'Pending'
        should remove start and end dates for any contract that was not 'Awarded'" do
      osp_obj.format
      expect(osp_obj.csv_hash[0]['grantcontract']).to eq('')
      expect(osp_obj.csv_hash[1]['grantcontract']).to eq('Grant')
      expect(osp_obj.csv_hash[0]['accessid']).to eq('abc123')
      expect(osp_obj.csv_hash[1]['accessid']).to eq('mar26')
      expect(osp_obj.csv_hash[2]['accessid']).to eq('jan2')
      expect(osp_obj.csv_hash[0]['role']).to eq('Co-Principal Investigator')
      expect(osp_obj.csv_hash[1]['role']).to eq('Core Faculty')
      expect(osp_obj.csv_hash[2]['role']).to eq('Post Doctoral Associate')
      expect(osp_obj.csv_hash[3]['role']).to eq('Unknown')
      expect(osp_obj.csv_hash[0]['submitted']).to eq('')
      expect(osp_obj.csv_hash[0]['awarded']).to eq('')
      expect(osp_obj.csv_hash[0]['startdate']).to eq('2017-01-01')
      expect(osp_obj.csv_hash[0]['enddate']).to eq('2018-12-12')
      expect(osp_obj.csv_hash[3]['status']).to eq('Pending')
      expect(osp_obj.csv_hash[1]['status']).to eq('Pending')
      expect(osp_obj.csv_hash[2]['startdate']).to eq('2017-01-01')
      expect(osp_obj.csv_hash[2]['enddate']).to eq('2018-12-12')
      expect(osp_obj.csv_hash[3]['startdate']).to eq('')
      expect(osp_obj.csv_hash[3]['enddate']).to eq('')
      expect(osp_obj.csv_hash[0].length).to eq(17)
      expect(osp_obj.csv_hash[1].length).to eq(17)
    end
  end

  context "#filter_by_date" do

    it "should remove rows with 'submitted' dates <= 2011" do
      osp_obj = OspFormat.new([headers, [1, 1, 'X', 'X', 'X', 'X', 'X', 'X', 'X', 1, 'X', '2001-01-01',
                              'X', 1, 1, 1, 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X'],
                              [1, 1, 'X', 'X', 'X', 'X', 'X', 'X', 'X', 1, 'X', '2013-02-01',
                              'X', 1, 1, 1, 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X'],
                              [1, 1, 'X', 'X', 'X', 'X', 'X', 'X', 'X', 1, 'X', '2020-03-01',
                              'X', 1, 1, 1, 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X'],
                              [1, 1, 'X', 'X', 'X', 'X', 'X', 'X', 'X', 1, 'X', '1989-04-01',
                              'X', 1, 1, 1, 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X']], book)

      osp_obj.filter_by_date
      expect(osp_obj.csv_hash.count).to eq(1)
    end
  end

  context "#filter_by_user" do

    it "should remove rows that contain non-active users" do
      osp_obj = OspFormat.new([headers, [1, 1, 'X', 'X', 'X', 'X', 'zzz999', 'X', 'X', 1,
                              'X', 'X', 'X', 1, 1, 1, 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X'],
                              [1, 1, 'X', 'X', 'X', 'X', 'xxx111', 'X', 'X', 1,
                              'X', 'X', 'X', 1, 1, 1, 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X']], book)

      osp_obj.filter_by_user
      expect(osp_obj.csv_hash.count).to eq(1)
      expect(osp_obj.csv_hash[0]['accessid']).to eq('zzz999')
      expect(osp_obj.csv_hash[0]['f_name']).to eq('Bill')
      expect(osp_obj.csv_hash[0].length).to eq(27)
    end
  end

  context "#filter_by_status" do

    it "should remove rows with 'Purged' or 'Withdrawn' status" do
      osp_obj = OspFormat.new([headers, [1, 1, 'X', 'X', 'X', 'X', 'X', 'X', 'X', 1,
                              'Purged', 'X', 'X', 1, 1, 1, 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X'],
                              [1, 1, 'X', 'X', 'X', 'X', 'X', 'X', 'X', 1,
                              'Awarded', 'X', 'X', 1, 1, 1, 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X'],
                              [1, 1, 'X', 'X', 'X', 'X', 'X', 'X', 'X', 1,
                              'Withdrawn', 'X', 'X', 1, 1, 1, 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X']], book)
    
      osp_obj.filter_by_status
      expect(osp_obj.csv_hash.count).to eq(1)
      expect(osp_obj.csv_hash[0]['status']).to eq('Awarded')
    end
  end

end

