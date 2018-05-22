require 'spreadsheet'
require 'csv'

class LionPathFormat

  attr_accessor :csv_object, :xls_object, :csv_hash

  #Creates CSV and XLS object.  Imported CSV must be tab delimited text.
  def initialize(csv_array = CSV.read('data/SP18-tabdel.txt', encoding: "ISO-8859-1:UTF-8", col_sep: "\t"),
                 xls_object = Spreadsheet.open('data/psu-users.xls'))
    @csv_hash = convert_to_hash(csv_array)
    @xls_object = xls_object.worksheet 0
    @active_users = find_active_users
    @flagged = []
  end

  def format
    csv_hash.each do |csv|
      format_ID(csv)
      format_term(csv)
      format_catalog_number(csv)
      format_section_code(csv)
      format_instruction_mode(csv)
    end
    csv_hash.each do |csv|
      add_xfields(csv)
    end
  end

  def filter_by_user
    kept_rows = []
    csv_hash.each do |csv|
      @active_users.each do |user|
        if user[3] == csv['Instructor Campus ID'].downcase
          csv['m_name'] = user[2]
          csv['l_name'] = user[0]
          csv['f_name'] = user[1]
          kept_rows << csv
        end
      end
    end
    @csv_hash = kept_rows
  end

  def remove_duplicates
    csv_hash.uniq!{ |hash| 
      [
        hash['Instructor Campus ID'],
        hash['Term'],
        hash['Calendar Year'],
        hash['Class Campus Code'],
        hash['Course Short Description'],
        hash['Course Long Description'],
        hash['Academic Course ID'],
        hash['Cross Listed Flag'],
        hash['Subject Code'],
        hash['Course Number'],
        hash['Course Suffix'],
        hash['Class Section Code'],
        hash['Course Credits/Units'],
        hash['Current Enrollment'],
        hash['Instruction Mode'],
        hash['Course Component'],
        hash['f_name'],
        hash['l_name'],
        hash['m_name'],
        hash['XCourse CoursePre'],
        hash['XCourse CourseNum'],
        hash['XCourse CourseNum Suffix']
      ]
    } 
  end

  def write_flagged_to_xl(filename = 'data/flagged_more_than_two.xls')
    wb = Spreadsheet::Workbook.new filename
    sheet = wb.create_worksheet
    @flagged[0].each do |k, v|
      sheet.row(0).push(k)
    end
    @flagged.uniq.each_with_index do |row, index|
      row.each do |k, v|
        sheet.row(index+1).push(v)
      end
    end
    wb.write filename
  end

  def write_results_to_xl(filename = 'data/lionpath_data-formatted.xls')
    wb = Spreadsheet::Workbook.new filename
    sheet = wb.create_worksheet
    csv_hash[0].each do |k, v|
      sheet.row(0).push(k)
    end
    csv_hash.each_with_index do |row, index|
      row.each do |k, v|
        sheet.row(index+1).push(v)
      end
    end
    wb.write filename
  end

  private

  def convert_to_hash(csv_array)
    keys = csv_array[0]
    csv_array[1..-1].map {|a| Hash[ keys.zip(a) ] }
  end

  #Creates a list of 'Enabled' and 'Has Access' AI users
  def find_active_users
    active_user_arr = []
    xls_object.drop(3).each do |xls|
      if xls[6].downcase == 'yes' && xls[7].downcase == 'yes'
        active_user_arr << [xls[0], xls[1], xls[2], xls[4].downcase]
      end
    end
    return active_user_arr
  end

  #Converts dates back into psuIDs
  def format_ID(csv)
    if csv['Instructor Campus ID'].include? '-'
      case
      when csv['Instructor Campus ID'].split('-')[0] != "1"
        csv['Instructor Campus ID'] = csv['Instructor Campus ID'].split('-')[1].downcase + csv['Instructor Campus ID'].split('-')[0]
      when csv['Instructor Campus ID'].split('-')[2] =~ /19\d{2}/
        csv['Instructor Campus ID'] = csv['Instructor Campus ID'].split('-')[1].downcase + csv['Instructor Campus ID'].split('-')[2][2..3]
      when csv['Instructor Campus ID'].split('-')[2] =~ /\d{4}/
        csv['Instructor Campus ID'] = csv['Instructor Campus ID'].split('-')[1].downcase + csv['Instructor Campus ID'].split('-')[2]
      end
    end
  end

  #Converts 'Term' from season and year to just season
  def format_term(csv)
    csv['Term'] = csv['Term'].split(' ')[0]
  end

  #Adds leading zeroes to 'Catalog Number' and converts to string
  #and splits 'Catalog Number' into 'Course Number' and 'Course Suffix'
  def format_catalog_number(csv)
    course_split = csv['Catalog Number'].to_s.split(/(?<=\d)(?=[A-Za-z])/)
    while course_split[0].length < 3
      course_split[0].to_s.prepend('0')
    end
    csv.delete('Catalog Number')
    csv['Course Number'] = course_split[0]
    csv['Course Suffix'] = course_split[1]
  end

  #Adds leading zeroes to 'Class Section Code' and splits suffix off
  def format_section_code(csv)
    section_split = csv['Class Section Code'].to_s.split(/(?<=\d)(?=[A-Za-z])/)
    while section_split[0].length < 3
      section_split[0].to_s.prepend('0')
    end
    csv['Class Section Code'] = section_split[0]
    csv['Course Suffix'] = section_split[1] unless csv['Course Suffix']
  end

  def format_instruction_mode(csv)
    if csv['Instruction Mode'].include? '-'
      csv['Instruction Mode'].gsub!('-', '–')
    end
  end

  #Adds data to 'XCourse CoursePre' 'XCourse CourseNum' and 'XCourse CourseNum Suffix'
  def add_xfields(csv)
    if csv['Cross Listed Flag'] == 'Y' 
      counter = 0
      xfield_arr = []
      csv_arr = [csv]
      csv_hash.each do |csv2|
        if csv['Academic Course ID'] == csv2['Academic Course ID'] && csv['Instructor Campus ID'] == csv2['Instructor Campus ID']
          unless csv == csv2
            csv_arr << csv2
            xfield_arr << [csv2['Subject Code'], csv2['Course Number'], csv2['Course Suffix']]
            counter += 1
          end
        end
      end
      if counter > 1
        csv_arr.each {|flag| @flagged << flag}
        csv['XCourse CoursePre'] = ' '
        csv['XCourse CourseNum'] = ' '
        csv['XCourse CourseNum Suffix'] = ' '
      elsif counter == 0
        csv['XCourse CoursePre'] = ' '
        csv['XCourse CourseNum'] = ' '
        csv['XCourse CourseNum Suffix'] = ' '
      else
        csv['XCourse CoursePre'] = xfield_arr[0][0]
        csv['XCourse CourseNum'] = xfield_arr[0][1]
        csv['XCourse CourseNum Suffix'] = xfield_arr[0][2]
      end
    else
      csv['XCourse CoursePre'] = ' '
      csv['XCourse CourseNum'] = ' '
      csv['XCourse CourseNum Suffix'] = ' '
    end
  end

end
