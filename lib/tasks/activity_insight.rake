require 'ai_manage_duplicates'

namespace :activity_insight do

  desc "Find duplicates for user"

  task find_duplicates: :environment do

    put_duplicates(xml_to_hash(get_congrant_xmls))

  end

  desc "Identify duplicate records from Activity Insight backup and delete them"

  task remove_duplicates: :environment do

    write_to_spreadsheet(grab_duplicates(csv_to_hashes))
    delete_duplicates(grab_duplicates(csv_to_hashes))

  end
end
