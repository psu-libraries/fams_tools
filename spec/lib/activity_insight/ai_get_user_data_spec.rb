require 'rails_helper'
require 'activity_insight/ai_get_user_data'

RSpec.describe GetUserData do
  
  let(:fake_book) do
    book = Spreadsheet::Workbook.new
    sheet = book.create_worksheet
    sheet.row(1).replace []
    sheet.row(2).replace ['Last Name', 'First Name', 'Middle Name', 'Email', 'Username', 'User ID', 'PSU ID #', 'Enabled?', 'Has Access to Manage Activities?',
                          'Date Created', 'Campus', 'Campus Name', 'College', 'College Name', 'Department', 'Division', 'Institute', 'School', 'Security']
    sheet.row(3).replace ['X', 'Bill', 'X', 'X', 'zzz999', '123', 'X', 'Yes', 'Yes', 'X', 'X', 'X', 'BA', 'X', 'X', 'X', 'X', 'X', 'X']
    sheet.row(4).replace ['X', 'Jimmy', 'X', 'X', 'xxx111', '321', 'X', 'No', 'No', 'X', 'X', 'X', 'AG', 'X', 'X', 'X', 'X', 'X', 'X']
    sheet
  end

  let(:get_user_data_obj) {GetUserData.new(fake_book)}

  describe '#call' do
    it 'should get user data' do
      get_user_data_obj.call
      expect(Faculty.all.count).to eq(1)
      expect(Faculty.find_by(access_id: 'zzz999').f_name).to eq('Bill')
      expect(Faculty.find_by(access_id: 'zzz999').college).to eq('BA')
    end
  end

end
