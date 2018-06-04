require 'rails_helper'
require 'osp_populate_db'

RSpec.describe 'osp_populate_db' do

  headers =  ['ospkey', 'title', 'sponsor', 'sponsortype', 'accessid', 'role', 'pctcredit', 'status',
              'submitted', 'awarded', 'requested', 'funded', 'totalanticipated', 'startdate', 'enddate',
              'grantcontract', 'baseagreement', 'm_name', 'l_name', 'f_name']

  let(:fake_sheet) do
    data_arr = []
    arr_of_hashes = []
    keys = headers
    data_arr << [1234, 'Cool Title', 'Cool Sponsor', 'Federal Agencies',
                 'abc123', 'Co-PI', 50, 'Pending', '2013-04-05',
                 '/  /', 1, 1, 1, '', '', '', '', 'Bird', 'Cat', 'Allen']
    data_arr << [4321, 'Cooler Title', 'Cool Sponsor', 'Federal Agencies',
                 'abc123', 'Co-PI', 50, 'Pending', '2013-04-05',
                 '/  /', 1, 1, 1, '', '', '', '', 'Bird', 'Cat', 'Allen']
    data_arr << [1234, 'Cool Title', 'Cool Sponsor', 'Federal Agencies',
                 'xyz123', 'Co-PI', 50, 'Pending', '2013-04-05',
                 '/  /', 1, 1, 1, '', '', '', '', 'Yawn', 'Zebra', 'Xylophone']
    data_arr << [1221, 'Coolest Title', 'Not as Cool Sponsor', 'Universities and Colleges',
                 'xyz123', 'Co-PI', 50, 'Pending', '2013-04-05',
                 '/  /', 1, 1, 1, '', '', '', '', 'Yawn', 'Zebra', 'Xylophone'] 
    data_arr.each {|a| arr_of_hashes << Hash[ keys.zip(a) ] }
    arr_of_hashes
  end

  let(:osp_populate_db_obj) {OspPopulateDB.allocate}

  describe 'populate database' do
    it 'should populate the database with osp data' do
      osp_populate_db_obj.osp_parser = OspParser.allocate
      osp_populate_db_obj.osp_parser.xlsx_hash = fake_sheet
      osp_populate_db_obj.populate
      expect(Sponsor.all.count).to eq(2)
      expect(Contract.all.count).to eq(3)
      expect(Faculty.all.count).to eq(2)
      expect(ContractFacultyLink.all.count).to eq(4)
      expect(Faculty.find_by(:access_id => 'abc123').contract_faculty_links.all.count).to eq(2)
      expect(Faculty.find_by(:access_id => 'abc123').contract_faculty_links.first.contract.sponsor.sponsor_name).to eq('Cool Sponsor')
    end
  end

end
