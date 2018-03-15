require 'osp_filter'
require 'osp_format'

namespace :osp_data do

  desc "Pull data from dmresults.csv.  
        Format and clean data.
        Join with ai-user-accounts.xls on username (accessid) to only import data for AI users.
        Further filtering.
        Save that data in the database within corresponding models."

  task filter: :environment do

    active_users = OspFilter.get_active_ai_users
    grants = OspFilter.find_active_grants(active_users)

  end

  task format: :environment do
    my_sheet = OspFormat.new
    my_sheet.format_accessid_field
    my_sheet.format_date_fields
    my_sheet.filter_by_date
    my_sheet.csv_object.each {|csv| puts csv[11]}
  end

end
