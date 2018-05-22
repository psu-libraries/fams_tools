require 'rails_helper'

RSpec.describe 'osp_data' do

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

  describe 'populate database' do
    it 'should populate the database with osp data' do
      fake_sheet.each do |row|
        begin
          sponsor = Sponsor.create(sponsor_name: row['sponsor'],
                                   sponsor_type: row['sponsortype'])

        rescue ActiveRecord::RecordNotUnique
          sponsor = Sponsor.find_by(sponsor_name: row['sponsor'])
        end

        begin
          contract = Contract.create(osp_key:           row['ospkey'],
                                     title:             row['title'],
                                     sponsor:           sponsor,
                                     status:            row['status'],
                                     submitted:         row['submitted'],
                                     awarded:           row['awarded'],
                                     requested:         row['requested'],
                                     funded:            row['funded'],
                                     total_anticipated: row['totalanticipated'],
                                     start_date:        row['startdate'],
                                     end_date:          row['enddate'],
                                     grant_contract:    row['grantcontract'],
                                     base_agreement:    row['baseagreement'])

        rescue ActiveRecord::RecordNotUnique
          contract = Contract.find_by(osp_key: row['ospkey'])
        end

        begin
          faculty = Faculty.create(access_id: row['accessid'],
                                   f_name:    row['f_name'],
                                   l_name:    row['l_name'],
                                   m_name:    row['m_name'])

        rescue ActiveRecord::RecordNotUnique
          faculty = Faculty.find_by(access_id: row['accessid'])
        end

        ContractFacultyLink.create(contract:   contract,
                                   faculty:    faculty,
                                   role:       row['role'],
                                   pct_credit: row['pctcredit'])
      end
    expect(Sponsor.all.count).to eq(2)
    expect(Contract.all.count).to eq(3)
    expect(Faculty.all.count).to eq(2)
    expect(ContractFacultyLink.all.count).to eq(4)
    expect(Faculty.find_by(:access_id => 'abc123').contract_faculty_links.all.count).to eq(2)
    expect(Faculty.find_by(:access_id => 'abc123').contract_faculty_links.first.contract.sponsor.sponsor_name).to eq('Cool Sponsor')
    end
  end

end
