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

    my_sheet.csv_object.each_with_index do |row|
      ContractGrant.create(osp_key:           row[0],
                           title:             row[1],
                           sponsor_name:      row[2],
                           sponsor_type:      row[3],
                           access_id:          row[4],
                           f_name:            row[5],
                           l_name:            row[6],
                           role:              row[7],
                           pct_credit:        row[8],
                           status:            row[9],
                           submitted:         row[10],
                           awarded:           row[11],
                           requested:         row[12],
                           funded:            row[13],
                           total_anticipated: row[14],
                           start_date:        row[15],
                           end_date:          row[16],
                           grant_contract:    row[17],
                           base_agreement:    row[18])
    end

    finish = Time.now
    puts(((finish - start)/60).to_s + ' minutes')
  end
end
