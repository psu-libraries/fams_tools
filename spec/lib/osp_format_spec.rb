require 'rails_helper'
require 'spreadsheet'
require 'osp_format'

RSpec.describe OspFormat do
  book = Spreadsheet::Workbook.new
  sheet = book.create_worksheet
  sheet.row(1).replace []
  sheet.row(2).replace []
  sheet.row(3).replace ['Last Name', 'First Name', 'Middle Name', 'Email', 'Username', 'PSU ID #', 'Enabled?', 'Has Access to Manage Activities?', 
                'Campus', 'Campus Name', 'College', 'College Name', 'Department', 'Division', 'Institute', 'School', 'Security']
  sheet.row(4).replace ['X', 'X', 'X', 'X', 'zzz999', 'X', 'Yes', 'Yes', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X']
  sheet.row(5).replace ['X', 'X', 'X', 'X', 'xxx111', 'X', 'No', 'No', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X']


  context "#format_grant_contract" do
        it "should convert nil to ' ' under 'grantcontract' column" do
      osp_obj = OspFormat.new([[1, 1, 'X', 'X', 'X', 'X', 'X', 'X', 'X', 1, 'X', 'X',
                              'X', 1, 1, 1, 'X', 'X', 'X', 'X', nil, 'X', 'X', 'X'],
                              [1, 1, 'X', 'X', 'X', 'X', 'X', 'X', 'X', 1, 'X', 'X',
                               'X', 1, 1, 1, 'X', 'X', 'X', 'X', 'Grant', 'X', 'X', 'X']], book)

      osp_obj.format_grant_contract
      expect(osp_obj.csv_object[0][20]).to eq('')
      expect(osp_obj.csv_object[1][20]).to eq('Grant')
    end
  end

  context "#format_accessid_field" do

    it "should convert calendar dates to accessids in 'accessid' column" do
      osp_obj = OspFormat.new([[1, 1, 'X', 'X', 'X', 'X', 'abc123', 'X', 'X', 1, 'X', 'X',
                              'X', 1, 1, 1, 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X'],
                              [1, 1, 'X', 'X', 'X', 'X', 'Mar-26', 'X', 'X', 1, 'X', 'X',
                              'X', 1, 1, 1, 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X'],
                              [1, 1, 'X', 'X', 'X', 'X', '2-Jan', 'X', 'X', 1, 'X', 'X',
                              'X', 1, 1, 1, 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X']], book)

      osp_obj.format_accessid_field
      expect(osp_obj.csv_object[0][6]).to eq('abc123')
      expect(osp_obj.csv_object[1][6]).to eq('mar26')
      expect(osp_obj.csv_object[2][6]).to eq('jan2')
    end
  end

  context "#format_role_field" do

    it "should convert 'CO-PI' to 'Co-Principal Investigator'
        'Faculty' to 'Core Faculty'
        'Post Doctoral' to 'Post Doctoral Associate' and
        'unknown' to 'Unknown' in 'role' column" do

      osp_obj = OspFormat.new([[1, 1, 'X', 'X', 'X', 'X', 'X', 'X', 'Co-PI', 1, 'X', 'X',
                              'X', 1, 1, 1, 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X'],
                              [1, 1, 'X', 'X', 'X', 'X', 'X', 'X', 'Faculty', 1, 'X', 'X',
                              'X', 1, 1, 1, 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X'],
                              [1, 1, 'X', 'X', 'X', 'X', 'X', 'X', 'Post Doctoral', 1, 'X', 'X',
                              'X', 1, 1, 1, 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X'],
                              [1, 1, 'X', 'X', 'X', 'X', 'X', 'X', 'unknown', 1, 'X', 'X',
                              'X', 1, 1, 1, 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X']], book)

      osp_obj.format_role_field
      expect(osp_obj.csv_object[0][8]).to eq('Co-Principal Investigator')
      expect(osp_obj.csv_object[1][8]).to eq('Core Faculty')
      expect(osp_obj.csv_object[2][8]).to eq('Post Doctoral Associate')
      expect(osp_obj.csv_object[3][8]).to eq('Unknown')
    end
  end

  context "#format_date_fields" do

    it "should remove time, '/', and '/ /' from date fields and convert dates to be sql friendly" do

      osp_obj = OspFormat.new([[1, 1, 'X', 'X', 'X', 'X', 'X', 'X', 'X', 1, 'X', '/',
                              '/  /', 1, 1, 1, '1/1/2017 12:00:00 AM', '12/12/2018 12:00:00 AM', 
                              'X', 'X', 'X', 'X', 'X', 'X']], book)

      osp_obj.format_date_fields
      expect(osp_obj.csv_object[0][11]).to eq('')
      expect(osp_obj.csv_object[0][12]).to eq('')
      expect(osp_obj.csv_object[0][16]).to eq('2017-01-01')
      expect(osp_obj.csv_object[0][17]).to eq('2018-12-12')
    end
  end

  context "#format_pending" do

    it "should change 'Pending Award' and 'Pending Proposal' status to 'Pending'" do

      osp_obj = OspFormat.new([[1, 1, 'X', 'X', 'X', 'X', 'X', 'X', 'X', 1, 'Pending Award', 'X',
                              'X', 1, 1, 1, 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X'],
                              [1, 1, 'X', 'X', 'X', 'X', 'X', 'X', 'X', 1, 'Pending Proposal', 'X',
                              'X', 1, 1, 1, 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X']], book)


      osp_obj.format_pending
      expect(osp_obj.csv_object[0][10]).to eq('Pending')
      expect(osp_obj.csv_object[1][10]).to eq('Pending')
    end
  end

  context "#format_start_end" do

    it "should remove start and end dates for any contract that was not 'Awarded'" do

      osp_obj = OspFormat.new([[1, 1, 'X', 'X', 'X', 'X', 'X', 'X', 'X', 1, 'Awarded', 'X',
                              'X', 1, 1, 1, '2017-01-01', '2018-12-12', 'X', 'X', 'X', 'X', 'X', 'X'],
                              [1, 1, 'X', 'X', 'X', 'X', 'X', 'X', 'X', 1, 'Purged', 'X',
                              'X', 1, 1, 1, '2017-01-01', '2018-12-12', 'X', 'X', 'X', 'X', 'X', 'X']], book)


      osp_obj.format_start_end
      expect(osp_obj.csv_object[0][16]).to eq('2017-01-01')
      expect(osp_obj.csv_object[0][17]).to eq('2018-12-12')
      expect(osp_obj.csv_object[1][16]).to eq('')
      expect(osp_obj.csv_object[1][17]).to eq('')
    end
  end

  context "#filter_by_date" do

    it "should remove rows with 'submitted' dates <= 2011" do
      osp_obj = OspFormat.new([[1, 1, 'X', 'X', 'X', 'X', 'X', 'X', 'X', 1, 'X', '2001-01-01',
                              'X', 1, 1, 1, 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X'],
                              [1, 1, 'X', 'X', 'X', 'X', 'X', 'X', 'X', 1, 'X', '2013-02-01',
                              'X', 1, 1, 1, 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X'],
                              [1, 1, 'X', 'X', 'X', 'X', 'X', 'X', 'X', 1, 'X', '2020-03-01',
                              'X', 1, 1, 1, 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X'],
                              [1, 1, 'X', 'X', 'X', 'X', 'X', 'X', 'X', 1, 'X', '1989-04-01',
                              'X', 1, 1, 1, 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X']], book)

      osp_obj.filter_by_date
      expect(osp_obj.csv_object.count).to eq(1)
    end
  end

  context "#remove_columns" do

    it "should remove the columns we don't need" do
      osp_obj = OspFormat.new([[1, 1, 'X', 'X', 'X', 'X', 'X', 'X', 'X', 1, 'X', 'X',
                              'X', 1, 1, 1, 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X'],
                              [1, 1, 'X', 'X', 'X', 'X', 'X', 'X', 'X', 1, 'X', 'X',
                              'X', 1, 1, 1, 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X']], book)

      osp_obj.remove_columns
      expect(osp_obj.csv_object[0].length).to eq(17)
      expect(osp_obj.csv_object[1].length).to eq(17)
    end
  end

  context "#filter_by_user" do

    it "should remove rows that contain non-active users" do
      osp_obj = OspFormat.new([[1, 'X', 'X', 'X', 'zzz999', 'X', 1,
                              'X', 'X', 'X', 1, 1, 1, 'X', 'X', 'X', 'X'],
                              [1, 'X', 'X', 'X', 'xxx111', 'X', 1,
                              'X', 'X', 'X', 1, 1, 1, 'X', 'X', 'X', 'X']], book)

      osp_obj.filter_by_user
      expect(osp_obj.csv_object.count).to eq(1)
      expect(osp_obj.csv_object[0][4]).to eq('zzz999')
      expect(osp_obj.csv_object[0].length).to eq(20)
    end
  end

  context "#filter_purged_withdrawn" do

    it "should remove rows with 'Purged' or 'Withdrawn' status" do
      osp_obj = OspFormat.new([[1, 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 1,
                              'Purged', 'X', 'X', 1, 1, 1, 'X', 'X', 'X', 'X'],
                              [1, 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 1,
                              'Awarded', 'X', 'X', 1, 1, 1, 'X', 'X', 'X', 'X'],
                              [1, 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 1,
                              'Withdrawn', 'X', 'X', 1, 1, 1, 'X', 'X', 'X', 'X']], book)
    
      osp_obj.filter_purged_withdrawn
      expect(osp_obj.csv_object.count).to eq(1)
      expect(osp_obj.csv_object[0][10]).to eq('Awarded')
    end
  end

end

