require 'rails_helper'
require 'osp_format'

RSpec.describe OspFormat do

  context "#format_grant_contract" do

    it "should convert nil to ' ' under 'grantcontract' column" do
      osp_obj = OspFormat.new([[1, 1, 'X', 'X', 'X', 'X', 'X', 'X', 'X', 1, 'X', 'X',
                              'X', 1, 1, 1, 'X', 'X', 'X', 'X', nil, 'X', 'X', 'X'],
                              [1, 1, 'X', 'X', 'X', 'X', 'X', 'X', 'X', 1, 'X', 'X',
                              'X', 1, 1, 1, 'X', 'X', 'X', 'X', 'Grant', 'X', 'X', 'X']])

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
                              'X', 1, 1, 1, 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X']])

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
                              'X', 1, 1, 1, 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X']])

      osp_obj.format_role_field
      expect(osp_obj.csv_object[0][8]).to eq('Co-Principal Investigator')
      expect(osp_obj.csv_object[1][8]).to eq('Core Faculty')
      expect(osp_obj.csv_object[2][8]).to eq('Post Doctoral Associate')
      expect(osp_obj.csv_object[3][8]).to eq('Unknown')
    end
  end

  context "#format_date_fields" do

    it "should removes time, '/', and '/ /' from date fields and convert mm/dd/yy to Date object" do

      osp_obj = OspFormat.new([[1, 1, 'X', 'X', 'X', 'X', 'X', 'X', 'Co-PI', 1, 'X', 'X',
                              'X', 1, 1, 1, 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X'],
                              [1, 1, 'X', 'X', 'X', 'X', 'X', 'X', 'Faculty', 1, 'X', 'X',
                              'X', 1, 1, 1, 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X'],
                              [1, 1, 'X', 'X', 'X', 'X', 'X', 'X', 'Post Doctoral', 1, 'X', 'X',
                              'X', 1, 1, 1, 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X'],
                              [1, 1, 'X', 'X', 'X', 'X', 'X', 'X', 'unknown', 1, 'X', 'X',
                              'X', 1, 1, 1, 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X']])

      osp_obj.format_role_field
      expect(osp_obj.csv_object[0][8]).to eq('Co-Principal Investigator')
      expect(osp_obj.csv_object[1][8]).to eq('Core Faculty')
      expect(osp_obj.csv_object[2][8]).to eq('Post Doctoral Associate')
      expect(osp_obj.csv_object[3][8]).to eq('Unknown')
    end
  end

end

