require 'ai_manage_duplicates'
require 'ai_get_userids'

namespace :activity_insight do

  desc "Find duplicates for user"

  task find_duplicates: :environment do

    ReturnSystemDups.new.call

  end

  desc "Identify duplicate records from Activity Insight backup and delete them"

  task remove_duplicates: :environment do

    RemoveSystemDups.new.call

  end

  desc "Import userids from AI into our db"

  task import_userids: :environment do
    
    ImportUserids.new.call

  end

end
