require 'osp_format'

namespace :osp_data do

  desc "Pull data from dmresults.csv.  
        Format and clean data.
        Join with ai-user-accounts.xls on username (accessid) to only import data for AI users.
        Further filtering.
        Save that data in the database within corresponding models."

  task format: :environment do
    start = Time.now
    my_sheet = OspFormat.new
    my_sheet.format_accessid_field
    my_sheet.format_date_fields
    my_sheet.format_pending
    my_sheet.format_start_end
    my_sheet.filter_by_date
    my_sheet.remove_columns
    my_sheet.filter_by_user
    my_sheet.write_results_to_xl
=begin    my_sheet.csv_object.each_with_index do |row, index|
      Contract.create(title:             row[1],
                      sponsor:           row[2],
                      status:            row[7],
                      osp_key:           row[0],
                      submitted:         row[8],
                      awarded:           row[9],
                      requested:         row[10],
                      funded:            row[11],
                      total_anticipated: row[12],
                      start_date:        row[13],
                      end_date:          row[14],
                      grant_contract:    row[15],
                      base_agreement:    row[16])
      Faculty.create(f_name
=end
    finish = Time.now
    puts(finish - start)
  end
end
