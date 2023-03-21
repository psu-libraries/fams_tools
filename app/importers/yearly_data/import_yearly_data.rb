require 'creek'

class YearlyData::ImportYearlyData
  attr_accessor :yearly_data_book

  def initialize(yearly_data_book)
    @yearly_data_book = Creek::Book.new(yearly_data_book).sheets[0].rows
  end

  def import
    convert_xlsx_to_hash(@yearly_data_book).each do |row|
      populate_db(row)
    end
  end

  private

  def convert_xlsx_to_hash(yearly_data_book)
    counter = 0
    keys = []
    data = []
    data_hashed = []
    yearly_data_book.each_with_index do |row, index|
      values = []
      if index == 0
        row.each {|k,v| keys << v}
      else
        row.each {|k,v| values << v}
        data << values
      end
      counter += 1
    end
    data.each {|a| data_hashed << Hash[ keys.zip(a) ] }
    return data_hashed
  end

  def populate_db(row)
    faculty = Faculty.find_by(access_id: row['USERNAME'])
    return if faculty.blank?

    yearly = Yearly.new({faculty: faculty}.merge!(yearly_data_attrs(row)))

    if yearly.persisted?
      yearly.update!(yearly_data_attrs(row))
    else
      yearly.save!
    end
  end

  def yearly_data_attrs(row)
    {
        academic_year: row['AC_YEAR'],
        campus: row['CAMPUS'],
        campus_name: row['CAMPUS_NAME'],
        college: row['COLLEGE'],
        college_name: row['COLLEGE_NAME'],
        school: row['SCHOOL'],
        division: row['DIVISION'],
        institute: row['INSTITUTE'],
        admin_dept1: row['ADMIN_DEP_1_DEP'],
        admin_dept1_other: row['ADMIN_DEP_1_DEP_OTHER'],
        admin_dept2: row['ADMIN_DEP_2_DEP'],
        admin_dept2_other: row['ADMIN_DEP_2_DEP_OTHER'],
        admin_dept3: row['ADMIN_DEP_3_DEP'],
        admin_dept3_other: row['ADMIN_DEP_3_DEP_OTHER'],
        title: row['TITLE'],
        rank: row['RANK'],
        tenure: row['TENURE'],
        endowed_position: row['ENDPOS'],
        graduate: row['GRADUATE'],
        time_status: row['TIME_STATUS'],
        hr_code: row['HR_CODE']
    }
  end
end