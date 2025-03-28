class YearlyData::ImportYearlyData
  attr_accessor :yearly_data_book, :headers

  def initialize(yearly_data_book)
    @yearly_data_book = CSV.open(yearly_data_book, encoding: 'Windows-1252:UTF-8', force_quotes: true, quote_char: '"')
    @headers = @yearly_data_book.first.map! { |h| h.gsub(/[\uFEFF\xEF\xBB\xBFï»¿]/, '') }
  end

  def import
    @yearly_data_book.each do |row|
      row = convert_csv_to_hash(row)
      populate_db(row)
    end
  end

  private

  def convert_csv_to_hash(row)
    headers.zip(row).to_h
  end

  def populate_db(row)
    faculty = Faculty.find_by(access_id: row['USERNAME'])
    return if faculty.blank?

    yearly = Yearly.find_by(faculty_id: faculty.id)

    if yearly.present?
      yearly.update!(yearly_data_attrs(row))
    else
      new_yearly = Yearly.new({ faculty: }.merge!(yearly_data_attrs(row)))
      new_yearly.save!
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
      next if i == 0
      break unless row.has_key?("ADMIN_DEP_#{i}_DEP")

      json["ADMIN_DEP_#{i}_DEP"] = row["ADMIN_DEP_#{i}_DEP"] if row["ADMIN_DEP_#{i}_DEP"]
      json["ADMIN_DEP_#{i}_DEP_OTHER"] = row["ADMIN_DEP_#{i}_DEP_OTHER"] if row["ADMIN_DEP_#{i}_DEP_OTHER"]
    end
    json.to_json
  end
end
