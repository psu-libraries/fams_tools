require 'importers/importers_helper'

RSpec.describe OspData::OspImporter do
  
  let(:headers) do
    ['ospkey', 'ordernumber', 'title', 'sponsor', 'sponsortype', 'parentsponsor',
     'accessid', 'department', 'role', 'pctcredit', 'status', 'submitted', 'awarded',
     'requested', 'funded', 'totalanticipated', 'startdate', 'enddate', 'totalstartdate',
     'totalenddate', 'grantcontract', 'baseagreement', 'agreementtype', 'agreement', 'notfunded',
     'effortacademic', 'effortsummer', 'effortcalendar']
  end

  let(:data_book1) do
    current_year = DateTime.now.year
    data_arr = []
    data_arr << [1, 1, 'Title &quot; &#39;', '', 'Associations, Institutes, Societies and Voluntary', '', 'abc123', '',
                 'Co-PI', 1, 'Awarded', '/', '/  /', 2, 1, 1, '01/01/2017 00:00:00', '12/12/2018 00:00:00', '', '',
                 '', '', '', '', '02/01/2015 00:00:00', 0.15, 0.16, 0.17]
    data_arr << [3, 1, '', '', '', '', '03/01/2026 00:00:00', '', 'Faculty', 1, 'Pending Proposal', '', '',
                 4, 1, 1, '', '', '', '', 'Grant', '', '', '', '/  /', 0, 0, 0]
    data_arr << [5, 1, '', '', '', '', "01/02/#{current_year.to_s} 00:00:00", '', 'Post Doctoral', 1, 'Awarded', '', '',
                 6, 1, 1, '01/01/2017 00:00:00', '12/12/2018 00:00:00', '', '', 'Grant', '', '', '', '/  /', 0.15, 0.15, 0.15]
    data_arr << [7, 1, '', '', '', '', '01/02/2018 00:00:00', '', 'unknown', 1, 'Pending Award', '', '',
                 8, 1, 1, '01/01/2017 00:00:00', '12/12/2018 00:00:00', '', '', 'Grant', '', '', '', '/  /', 0.15, 0.15, 0.15]
    data_arr
  end

  let(:data_book2) do
    data_arr = []
    data_arr << [1, 1, '', '', '', '', '', '', '', 1, '', '01/01/2001 00:00:00', '', 1, 1, 1, '', '', '', '', '', '', '', '', '', 0.15, 0.15, 0.15]
    data_arr << [2, 1, '', '', '', '', '', '', '', 1, '', '01/02/2013 00:00:00', '', 1, 1, 1, '', '', '', '', '', '', '', '', '', 0.15, 0.15, 0.15]
    data_arr << [3, 1, '', '', '', '', '', '', '', 1, '', "12/31/#{(DateTime.now.year + 1).to_s} 00:00:00",
                 '', 1, 1, 1, '', '', '', '', '', '', '', '', '', 0.15, 0.15, 0.15]
    data_arr << [4, 1, '', '', '', '', '', '', '', 1, '', '01/03/1989 00:00:00', '', 1, 1, 1, '', '', '', '', '', '', '', '', '', 0.15, 0.15, 0.15]
    data_arr << [5, 1, '', '', '', '', '', '', '', 1, '', '',
                 '01/02/2013 00:00:00', 1, 1, 1, '', '', '', '', '', '', '', '', '', 0.15, 0.15, 0.15]
    data_arr << [6, 1, '', '', '', '', '', '', '', 1, '', '',
                 '', 1, 1, 1, '', '', '', '', '', '', '', '', '', 0.15, 0.15, 0.15]
    data_arr
  end

  let(:data_book3) do
    data_arr = []
    data_arr << [1, 1, '', '', '', '', 'zzz999', '', '', 1,
                 '', '', '', 1, 1, 1, '', '', '', '', '', '', '', '', '', 0.15, 0.15, 0.15]
    data_arr << [2, 1, '', '', '', '', 'xxx111', '', '', 1, '', '', '', 1, 1, 1, '', '', '', '', '', '', '', '', '', 0.15, 0.15, 0.15]
    data_arr
  end

  let(:data_book4) do
    data_arr = []
    data_arr << [1, 1, '', '', '', '', '', '', '', 1, 'Purged', '', '', 1, 1, 1, '', '', '', '', '', '', '', '', '', 0.15, 0.15, 0.15]
    data_arr << [2, 1, '', '', '', '', '', '', '', 1, 'Awarded', '', '', 1, 1, 1, '', '', '', '', '', '', '', '', '', 0.15, 0.15, 0.15]
    data_arr << [3, 1, '', '', '', '', '', '', '', 1, 'Withdrawn', '', '', 1, 1, 1, '', '', '', '', '', '', '', '', '', 0.15, 0.15, 0.15]
    data_arr << [123456, 1, '', '', '', '', '', '', '', 1, 'Withdrawn', '', '', 1, 1, 1, '', '', '', '', '', '', '', '', '', 0.15, 0.15, 0.15]
    data_arr << [193848, 1, '', '', '', '', '', '', '', 1, 'Purged', '', '', 1, 1, 1, '', '', '', '', '', '', '', '', '', 0.15, 0.15, 0.15]
    data_arr
  end

  let(:data_book5) do
    data_arr = []
    data_arr << [1234, 1, 'Cool Title', 'Cool Sponsor', 'Federal Agencies', '',
                 'abc123', 'Department', 'Co-PI', 50, 'Pending', '05/04/2013 00:00:00',
                 '/  /', 1, 1, 1, '', '', '', '', '', '', '', '', '02/02/2015 00:00:00', '', 0.15, 0.15, 0.15]
    data_arr << [4321, 1, 'Cooler Title', 'Cool Sponsor', 'Federal Agencies', '',
                 'abc123', 'Department', 'Co-PI', 50, 'Pending', '05/04/2013 00:00:00',
                 '/  /', 1, 1, 1, '', '', '', '', '', '', '', '', '', '', 0.15, 0.15, 0.15]
    data_arr << [1234, 1, 'Cool Title', 'Cool Sponsor', 'Federal Agencies', '',
                 'xyz123', 'Department', 'Co-PI', 50, 'Pending', '04/05/2013 00:00:00',
                 '/  /', 1, 1, 1, '', '', '', '', '', '', '', '', '03/02/2015 00:00:00', '', 0.15, 0.15, 0.15]
    data_arr << [1221, 1, 'Coolest Title', 'Not as Cool Sponsor', 'Universities and Colleges', '',
                 'xyz123', 'Department', 'Co-PI', 50, 'Pending', '04/05/2013 00:00:00',
                 '/  /', 1, 1, 1, '', '', '', '', '', '', '', '', '', '', 0.15, 0.15, 0.15]
    data_arr
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
    allow_any_instance_of(OspData::OspImporter).to receive(:headers).and_return headers
  end


  let(:osp_parser_obj) {OspData::OspImporter.new}

  describe "#format_and_populate" do
    it "should convert nils to ' ' and 
        should convert calendar dates to accessids in the 'accessid' column
        should convert 'Co-PI' to 'Co-Principal Investigator', 'Faculty' to 'Core Faculty', 
        should convert 'Post Doctoral' to 'Post Doctoral Associate', and 'unknown' to 'Unknown'
        should remove time, '/', and '/ /' from date fields and 
        should convert dates to be sql friendly
        should change 'Pending Award' and 'Pending Proposal' status to 'Pending'
        should remove start and end dates for any contract that was not 'Awarded'
        should convert sponsortype to appropriate drop down values" do
      allow(CSV).to receive(:open).and_return(data_book1)
      allow(CSV).to receive(:foreach).and_yield(fake_backup[0]).and_yield(fake_backup[1]).and_yield(fake_backup[2])
      allow_any_instance_of(OspData::OspImporter).to receive(:is_user).and_return(true)
      allow_any_instance_of(OspData::OspImporter).to receive(:is_good_date).and_return(true)
      allow_any_instance_of(OspData::OspImporter).to receive(:is_proper_status).and_return(true)
      osp_parser_obj.format_and_populate
      expect(Contract.first.grant_contract).to eq('')
      expect(Contract.first.title).to match(/Title " '/)
      expect(Contract.first.sponsor.sponsor_type).to eq('Associations, Institutes, Societies and Voluntary Health Agencies')
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
      expect(Contract.first.effort_academic).to eq(0.15)
      expect(Contract.first.effort_summer).to eq(0.16)
      expect(Contract.first.effort_calendar).to eq(0.17)
      expect(Contract.second.effort_academic).to eq(0)
      expect(Contract.second.effort_summer).to eq(0)
      expect(Contract.second.effort_calendar).to eq(0)
    end
  end

  context "#is_good_date" do

    it "should remove rows with 'submitted' dates <= 2011" do
      allow(CSV).to receive(:open).and_return(data_book2)
      allow(CSV).to receive(:foreach).and_yield(fake_backup[0]).and_yield(fake_backup[1]).and_yield(fake_backup[2])
      allow_any_instance_of(OspData::OspImporter).to receive(:is_proper_status).and_return(true)
      allow_any_instance_of(OspData::OspImporter).to receive(:is_user).and_return(true)
      osp_parser_obj.format_and_populate
      expect(Contract.count).to eq(2)
    end
  end

  context "#is_user" do

    it "should remove rows that contain non-active users" do
      allow(CSV).to receive(:open).and_return(data_book3)
      allow(CSV).to receive(:foreach).and_yield(fake_backup[0]).and_yield(fake_backup[1]).and_yield(fake_backup[2])
      allow_any_instance_of(OspData::OspImporter).to receive(:is_proper_status).and_return(true)
      allow_any_instance_of(OspData::OspImporter).to receive(:is_good_date).and_return(true)
      osp_parser_obj.format_and_populate
      expect(Contract.count).to eq(1)
      expect(Contract.first.contract_faculty_links.first.faculty.access_id).to eq('zzz999')
    end
  end

  context "#filter_by_status" do

    it "should remove rows with 'Purged' or 'Withdrawn' status" do
      allow(CSV).to receive(:open).and_return(data_book4)
      allow(CSV).to receive(:foreach).and_yield(fake_backup[0]).and_yield(fake_backup[1]).and_yield(fake_backup[2])
      allow_any_instance_of(OspData::OspImporter).to receive(:is_good_date).and_return(true)
      allow_any_instance_of(OspData::OspImporter).to receive(:is_user).and_return(true)
      osp_parser_obj.format_and_populate
      expect(Contract.count).to eq(3)
      expect(Contract.first.status).to eq('Awarded')
      expect(Contract.second.status).to eq('Withdrawn')
      expect(Contract.third.status).to eq('Purged')
    end
  end

  context '#populate_db_with_row' do
    it 'should populate the database with osp data' do
      allow(CSV).to receive(:open).and_return(data_book5)
      allow(CSV).to receive(:foreach).and_yield(fake_backup[0]).and_yield(fake_backup[1]).and_yield(fake_backup[2])
      allow_any_instance_of(OspData::OspImporter).to receive(:is_user).and_return(true)
      allow_any_instance_of(OspData::OspImporter).to receive(:is_good_date).and_return(true)
      allow_any_instance_of(OspData::OspImporter).to receive(:is_proper_status).and_return(true)
      osp_parser_obj.format_and_populate
      expect(Sponsor.all.count).to eq(2)
      expect(Contract.all.count).to eq(3)
      expect(Faculty.all.count).to eq(6)
      expect(ContractFacultyLink.all.count).to eq(4)
      expect(Faculty.find_by(access_id: 'abc123').contract_faculty_links.all.count).to eq(2)
      expect(Faculty.find_by(access_id: 'abc123').contract_faculty_links.first.contract.sponsor.sponsor_name).to eq('Cool Sponsor')
      expect(Contract.find_by(osp_key: 1234).notfunded).to eq(Date.parse('Sun, 02 Feb 2015'))
    end
  end
end

