require 'osp_format'

namespace :osp_data do

  desc "Pull data from dmresults.csv.  
        Format and clean data.
        Join with ai-user-accounts.xls on username (accessid) to only import data for AI users.
        Further filtering.
        Save that data in the database within corresponding models."

  task format: :environment do
    my_sheet = OspFormat.new
    my_sheet.format_accessid_field
    my_sheet.format_date_fields
    my_sheet.filter_by_date
    my_sheet.remove_columns
    my_sheet.filter_by_user
    my_sheet.csv_object.each {|csv| puts csv}
  end

end
