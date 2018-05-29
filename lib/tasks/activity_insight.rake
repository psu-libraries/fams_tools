require 'ai_manage_duplicates'
require 'ai_get_userids'

namespace :activity_insight do

  desc "Find duplicates for user"

  task find_duplicates: :environment do

    ReturnSystemDups.new([]).call

  end

  desc "Identify duplicate records from Activity Insight backup and delete them"

  task remove_duplicates: :environment do

    write_to_spreadsheet(grab_duplicates(csv_to_hashes))
    delete_duplicates(grab_duplicates(csv_to_hashes))

  end

  desc "Import userids from AI into our db"

  task import_userids: :environment do
    
    ImportUserids.new.call

  end
end
