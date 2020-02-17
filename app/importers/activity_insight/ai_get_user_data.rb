require 'spreadsheet'

class GetUserData
  attr_accessor :users_sheet, :users_hashed

  def initialize(file_path = 'data/psu-users.xls')
    @users_sheet = Spreadsheet.open(file_path).worksheet(0)
    @users_hashed = []
  end

  def call
    convert_xls_to_hash(users_sheet)
    populate_active_users(users_hashed)
  end

  private 

  def convert_xls_to_hash(users_sheet)
    keys = users_sheet.row(2)
    users_sheet.drop(2).each do |row|
      users_hashed << Hash[ keys.zip(row) ]
    end
  end

  def populate_active_users(users_hashed)
    users_hashed.each do |row|
      faculty = Faculty.find_or_create_by(access_id: row['Username'].downcase)
      next if faculty.blank?

      if row['Enabled?'].downcase == 'yes' && row['Has Access to Manage Activities?'].downcase == 'yes'
        faculty.update_attributes({
          user_id:   row['User ID'],
          f_name:    row['First Name'],
          l_name:    row['Last Name'],
          m_name:    row['Middle Name'],
          college:   row['College'],
          campus:   row['Campus']})
      else
        faculty.delete
      end
    end
  end

end

