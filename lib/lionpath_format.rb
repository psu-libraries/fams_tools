require 'spreadsheet'
require 'csv'

class LionPathFormat

  attr_accessor :csv_object, :xls_object, :csv_hash

  #Creates CSV and XLS object.  Imported CSV must be tab delimited text.
  def initialize(csv_array = CSV.read('data/SP18-tabdel.txt', encoding: "ISO8859-1", col_sep: "\t"),
                 xls_object = Spreadsheet.open('data/psu-users.xls'))
    @csv_hash = convert_to_hash(csv_array)
    @xls_object = xls_object.worksheet 0
    @active_users = find_active_users
  end

  def format
    csv_hash.each do |csv|
      format_ID(csv)
      format_term(csv)
      format_catalog_number(csv)
      format_section_code(csv)
    end
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

  #Adds leading zeroes to 'Class Section Code'
  def format_section_code(csv)
    section_split = csv['Class Section Code'].to_s.split(/(?<=\d)(?=[A-Za-z])/)
    while section_split[0].length < 3
      section_split[0].to_s.prepend('0')
    end
    csv['Class Section Code'] = section_split.join('')
  end

end
