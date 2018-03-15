require 'spreadsheet'

class OspFilter

  # Writes a hash to the filename provided.
  # Should use the key for the first row of headers
  def self.write_results_to_xl(h, filename)

    wb = Spreadsheet::Workbook.new filename
    sheet = wb.create_worksheet

    h.each_with_index do |row, index|

      row = row.sort_by{ |k, v| k}.to_h
      
      # Write the keys for the heading only in first row
      if index == 0
        row.each_key do |k|
          sheet.row(0).push(k)
        end 
      end

      # Write all values, starting row index off zero
      # Since 0 is the heading row
      row.each do |key, value|
        sheet.row(index+1).push(value)
      end
    end

    wb.write filename
  end

  # Loop over OSP file of grants and if the users 
  # on the grants are active AI users then consider that
  # grant and user information for the 'found' hash, if
  # the user on the grant is not an active AI user then 
  # consider that user 'not_found'
  def self.find_active_grants(user_hash)

    osp_file = 'data/dmresults-filtered.xls'
    osp_array = self.excel_to_hash osp_file
    grant_info = {}
    found = [] 
    not_found = [] 

    osp_array.each_with_index do |row, i|

      next if row["accessid"].blank?

      if user_hash.key?(row["accessid"].downcase)
        user_hash[row['accessid']].each do |k,v|
          row[k] = v
        end
        found  << row
      else
        not_found << row
      end
    end 
    
    puts "found:#{found.count()}"
    puts "not found:#{not_found.count()}"
    grant_info['found'] = found
    grant_info['not_found'] = not_found
    grant_info
  end

  # Search an excel spreadsheet and find any user that is considered 
  # to be an active or enable user for activity insight
  def self.get_active_ai_users

    ai_file = 'data/ai-user-accounts.xls' 
    ai_array = self.excel_to_hash ai_file
    ai_active = {}

    ai_array.each do |row|

      if row["Enabled"].downcase.eql? "yes"
        ai_active[row['Username'].downcase] =  row
      end
    end

    ai_active
  end

  # Opens a spreadsheet and creates a hash based on column names
  # and finds a predetermined list of fields that are considered dates
  # and properly formats those date fields (otherwise they come through as
  # floats
  def self.excel_to_hash(sheet_name)

    my_book = Spreadsheet.open sheet_name 
    my_sheet = my_book.worksheet 0
    my_sheet2 = my_book.worksheet 1
    # These are the fields, that if found will be converted to dates
    date_fields = ['submitted', 'awarded', 'startdate', 'enddate', 'totalstartdate', 'totalenddate']
    # These are the fields, that if found will be deleted
    skip_fields = ['ordernumber', 'department', 'agreementtype', 'agreement', 'Campus', 'Campus Name', 
                   'College Name', 'Department', 'Division', 'Email', 'Has Manage Your Activities',
                   'PSU ID #', 'School', 'Security']
    rows = [] 
    header = my_sheet.row(0)

    my_sheet.each_with_index 1 do |row, index|

      row_data = Hash[*header.zip(row).flatten]
      row_data.each_key{|x| row_data[x].to_s.downcase.strip if row_data[x]}
      row_data.each do |k,v|

        if date_fields.include?(k) and not v.blank? and v.is_a?(Numeric)
          v = DateTime.new(1899,12,30) + v
          v = v.strftime("%m-%d-%Y")
          row_data[k] = v
        end
      end

      # Puts "rowdata before: #{row_data}"
      skip_fields.each { |k| row_data.delete k}
      puts "rowdata after: #{row_data}"
      rows << row_data      
    end

    rows
  end

end
