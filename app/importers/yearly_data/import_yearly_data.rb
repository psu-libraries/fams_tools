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
        departments: departments(row),
        title: row['TITLE'],
        rank: row['RANK'],
        tenure: row['TENURE'],
        endowed_position: row['ENDPOS'],
        graduate: row['GRADUATE'],
        time_status: row['TIME_STATUS'],
        hr_code: row['HR_CODE']
    }
  end

  def departments(row)
    json = {}
    6.times do |i|
        #byebug
      next if i == 0
      break if !row.has_key?("ADMIN_DEP_#{i}_DEP")
      json["ADMIN_DEP_#{i}_DEP"] = row["ADMIN_DEP_#{i}_DEP"] if row["ADMIN_DEP_#{i}_DEP"] 
      json["ADMIN_DEP_#{i}_DEP_OTHER"] = row["ADMIN_DEP_#{i}_DEP_OTHER"] if row["ADMIN_DEP_#{i}_DEP_OTHER"] 
    end
    json.to_json
  end
end