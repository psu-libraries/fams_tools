require 'spreadsheet'
require 'csv'

class LionPathParser

  attr_accessor :csv_hash, :active_users, :csv_object

  def initialize(filepath = 'data/creditcoursestaught.txt')
    @csv_object = CSV.read(filepath, encoding: "ISO-8859-1:UTF-8", quote_char: '"', force_quotes: true)
    @csv_hash = convert_csv_to_hash(csv_object)
    @active_users = Faculty.pluck(:access_id)
    @flagged = []
  end

  def format
    csv_hash.each do |row|
      format_term(row)
      format_catalog_number(row)
      format_section_code(row)
    end
    csv_hash.each do |row|
      add_xfields(row)
    end
  end

  def filter_campus
    kept_rows = []
    csv_hash.each do |row|
      kept_rows.push(row) unless row['Class Campus Code'] == 'XS'
    end
    @csv_hash = kept_rows
  end

  def filter_by_user
    kept_rows = []
    csv_hash.each do |row|
      next if row['Instructor Campus ID'].nil?

      if active_users.include? row['Instructor Campus ID'].downcase
        kept_rows << row
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
        hash['Academic Course ID'],
        hash['Cross Listed Flag'],
        hash['Subject Code'],
        hash['Course Number'],
        hash['Course Suffix'],
        hash['Class Section Code'],
        hash['Course Component']
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

  private

  def convert_csv_to_hash(csv_array)
    keys = csv_array[0]
    keys[0].gsub!("ï»¿".force_encoding("UTF-8"), '')
    csv_array[1..-1].map{ |a| Hash[ keys.zip(a) ] }
  end

  #Converts 'Term' from season and year to just season
  def format_term(row)
    row['Term'] = row['Term'].split(' ')[0]
    if row['Term'] == 'Summer'
      row['Term'] = 'Summer 1'
    end
  end

  #Adds leading zeroes to 'Catalog Number' and converts to string
  #and splits 'Catalog Number' into 'Course Number' and 'Course Suffix'
  def format_catalog_number(row)
    course_split = row['Catalog Number'].to_s.strip.split(/(?<=\d)(?=[A-Za-z])/)
    while course_split[0].length < 3
      course_split[0].to_s.prepend('0')
    end
    row.delete('Catalog Number')
    row['Course Number'] = course_split[0].to_s
    row['Course Suffix'] = course_split[1]
  end

  #Adds leading zeroes to 'Class Section Code' and splits suffix off
  def format_section_code(row)
    section_split = row['Class Section Code'].to_s.strip.split(/(?<=\d)(?=[A-Za-z])/)
    while section_split[0].length < 3
      section_split[0].to_s.prepend('0')
    end
    row['Class Section Code'] = section_split.join('')
  end

  #Adds data to 'XCourse CoursePre' 'XCourse CourseNum' and 'XCourse CourseNum Suffix'
  def add_xfields(row)
    if row['Cross Listed Flag'] == 'Y' 
      counter = 0
      xfield_arr = []
      csv_arr = [row]
      csv_hash.each do |row2|
        if row['Academic Course ID'] == row2['Academic Course ID'] && row['Instructor Campus ID'] == row2['Instructor Campus ID']
          unless row == row2
            csv_arr << row2
            xfield_arr << [row2['Subject Code'], row2['Course Number'], row2['Course Suffix']]
            counter += 1
          end
        end
      end
      if counter > 1
        csv_arr.each {|flag| @flagged << flag}
        row['XCourse CoursePre'] = ''
        row['XCourse CourseNum'] = ''
        row['XCourse CourseNum Suffix'] = ''
      elsif counter == 0
        row['XCourse CoursePre'] = ''
        row['XCourse CourseNum'] = ''
        row['XCourse CourseNum Suffix'] = ''
      else
        row['XCourse CoursePre'] = xfield_arr[0][0]
        row['XCourse CourseNum'] = xfield_arr[0][1]
        row['XCourse CourseNum Suffix'] = xfield_arr[0][2]
      end
    else
      row['XCourse CoursePre'] = ''
      row['XCourse CourseNum'] = ''
      row['XCourse CourseNum Suffix'] = ''
    end
  end

end
