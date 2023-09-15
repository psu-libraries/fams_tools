require 'importers/importers_helper'

RSpec.describe ActivityInsight::GetUserData do
  let!(:faculty1) { FactoryBot.create(:faculty, access_id: 'xxx111') }

  let(:fake_book) do
    book = Spreadsheet::Workbook.new
    sheet = book.create_worksheet
    sheet.row(1).replace []
    sheet.row(2).replace ['Last Name', 'First Name', 'Middle Name', 'Email', 'Username', 'User ID', 'PSU ID #', 'Enabled?', 'Has Access to Manage Activities?',
                          'Date Created', 'Campus', 'Campus Name', 'College', 'College Name', 'Department', 'Division', 'Institute', 'School', 'Security', 'Penn State Health Username']
    sheet.row(3).replace ['X', 'Bill', 'X', 'X', 'zzz999', '123', 'X', 'Yes', 'Yes', 'X', 'UP', 'X', 'MD', 'X', 'X', 'X', 'X', 'X', 'X', 'abc1234']
    sheet.row(4).replace ['X', 'Jimmy', 'X', 'X', 'xxx111', '321', 'X', 'No', 'No', 'X', 'UP', 'X', 'AG', 'X', 'X', 'X', 'X', 'X', 'X', 'X']
    sheet
  end

  let(:get_user_data_obj) { ActivityInsight::GetUserData.new }

  describe '#call' do
    it 'gets user data' do
      expect(Faculty.find(faculty1.id)).to be_present
      allow(Spreadsheet).to receive_message_chain(:open, :worksheet) { fake_book }
      get_user_data_obj.call
      expect(Faculty.all.count).to eq(1)
      expect(Faculty.find_by(access_id: 'zzz999').f_name).to eq('Bill')
      expect(Faculty.find_by(access_id: 'zzz999').college).to eq('MD')
      expect(Faculty.find_by(access_id: 'zzz999').campus).to eq('UP')
      expect(Faculty.find_by(access_id: 'zzz999').com_id).to eq('abc1234')
    end
  end
end
