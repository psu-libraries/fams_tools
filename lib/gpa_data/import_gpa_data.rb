require 'creek'

class ImportGpaData
  attr_accessor :gpa_data_book

  def initialize(gpa_data_book)
    @gpa_data_book = Creek::Book.new(gpa_data_book).sheets[0].rows
  end

  def import
    convert_xlsx_to_hash(@gpa_data_book).each do |row|
      populate_db(row)
    end
  end

  private

  def convert_xlsx_to_hash(gpa_data_book)
    counter = 0
    keys = []
    data = []
    data_hashed = []
    gpa_data_book.each_with_index do |row, index|
      next if index == 0

      values = []
      if counter == 0
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
    faculty = Faculty.find_by(access_id: row['Access ID'])

    gpa = Gpa.new({faculty: faculty}.merge!(gpa_data_attrs(row, faculty)))

    if gpa.persisted?
      gpa.update_attributes!(gpa_data_attrs(row, faculty))
    else
      gpa.save!
    end
  end

  def gpa_data_attrs(row, faculty)
    {
        course_number: course_number(row),
        semester: semester(row),
        year: year(row),
        course_prefix: course_prefix(row),
        course_number_suffix: course_number_suffix(row),
        section_number: section_number(row),
        campus: faculty.campus,
        number_of_grades: row['N Grades'],
        course_gpa: row['Course GPA'],
        grade_dist_a: row['A'],
        grade_dist_a_minus: row['A_MINUS'],
        grade_dist_b_plus: row['B_PLUS'],
        grade_dist_b: row['B'],
        grade_dist_b_minus: row['B_MINUS'],
        grade_dist_c_plus: row['C_PLUS'],
        grade_dist_c: row['C'],
        grade_dist_d: row['D'],
        grade_dist_f: row['F'],
        grade_dist_w: row['W'],
        grade_dist_ld: row['LD'],
        grade_dist_other: row['Other']
    }
  end

  def course_number(row)
    row['Course & Sect(s)'].split(' ')[1].split('.')[0].scan(/\d+|\D+/)[0].to_s
  end

  def year(row)
    row["Sem"][0..2].insert(1, "0").to_i
  end

  def semester(row)
    case row['Sem'][3].to_i
    when 1
      return 'Spring'
    when 5
      return 'Summer 1'
    when 8
      return 'Fall'
    else
      return nil
    end
  end

  def course_prefix(row)
    row['Course & Sect(s)'].split(' ')[0]
  end

  def course_number_suffix(row)
    row['Course & Sect(s)'].split(' ')[1].split('.')[0].scan(/\d+|\D+/)[1]
  end

  def section_number(row)
    row['Course & Sect(s)'].split(' ')[1].split('.')[1].to_s
  end
end