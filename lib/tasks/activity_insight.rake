namespace :activity_insight do

  desc "Find duplicates for user"

  task find_duplicates: :environment do

    start = Time.now
    my_return_dups = ReturnSystemDups.new()
    my_return_dups.call
    finish = Time.now
    puts(((finish - start)/60).to_s + ' mins')

  end

  desc "Identify duplicate records from Activity Insight backup and delete them"

  task remove_duplicates: :environment do

    start = Time.now
    my_remove_dups = RemoveSystemDups.new(target = :beta)
    my_remove_dups.call
    #my_remove_dups.write
    finish = Time.now
    puts(((finish - start)/60).to_s + ' mins')

  end

  desc "Get user data from Activity Insight Spreadsheet"

  task get_user_data: :environment do

    start = Time.now
    my_get_user_data = GetUserData.new
    my_get_user_data.call
    finish = Time.now
    puts(((finish - start)/60).to_s + ' mins')

  end

  task :delete_records, [:resource, :target] do |task, args|

    start = Time.now
    DeleteRecords.new(args[:resource], args[:target]).delete
    finish = Time.now
    puts(((finish - start)/60).to_s + ' mins')

  end

end
