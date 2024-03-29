namespace :activity_insight do
  desc 'Find duplicates for user'

  task find_duplicates: :environment do
    start = Time.now
    my_return_dups = ActivityInsight::ReturnSystemDups.new
    my_return_dups.call
    finish = Time.now
    puts(((finish - start) / 60).to_s + ' mins')
  end

  desc 'Identify duplicate records from Activity Insight backup and delete them'

  task remove_duplicates: :environment do
    start = Time.now
    my_remove_dups = ActivityInsight::RemoveSystemDups.new(target = :beta)
    my_remove_dups.call
    # my_remove_dups.write
    finish = Time.now
    puts(((finish - start) / 60).to_s + ' mins')
  end

  desc "Get user data from Activity Insight's psu-users.xls file"

  task get_user_data: :environment do
    Rails.application.eager_load!

    start = Time.now
    username = Rails.application.config_for(:activity_insight)['main'][:username]
    password = Rails.application.config_for(:activity_insight)['main'][:password]
    f_path = File.join('app', 'parsing_files', 'psu-users.xls')
    `bin/psu-users.sh #{username} #{password}`
    Faculty.delete_all
    my_get_user_data = ActivityInsight::GetUserData.new(f_path)
    my_get_user_data.call
    File.delete(f_path) if File.exist?(f_path)
    finish = Time.now
    puts(((finish - start) / 60).to_s + ' mins')
  end

  task :delete_records, [:resource, :target] do |_task, args|
    Rails.application.eager_load!

    start = Time.now
    ActivityInsight::DeleteRecords.new(args[:resource], args[:target].to_sym).delete
    finish = Time.now
    puts(((finish - start) / 60).to_s + ' mins')
  end

  task :delete_compounded_congrants, [:csv_path, :target] do |_task, args|
    Rails.initialize!

    start = Time.now
    file_path = "#{Rails.root.join('app/parsing_files/delete.csv')}"
    File.delete(file_path) if File.exist?(file_path)
    CSV.open(file_path, 'wb') do |csv|
      csv << ['ID']
      CSV.foreach(args[:csv_path], headers: true, encoding: 'ISO8859-1:UTF-8', force_quotes: true, quote_char: '"',
                                   liberal_parsing: true) do |row|
        if (row['ORIGINAL_SOURCE'] == 'IMPORT') && row['OSPKEY'].present? && row['BASE_AGREE'].present?
          csv << [row['ID']]
        end
      end
    end
    ActivityInsight::DeleteRecords.new('CONGRANT', args[:target]).delete
    File.delete(file_path) if File.exist?(file_path)
    finish = Time.now
    puts(((finish - start) / 60).to_s + ' mins')
  end

  desc 'Uses post-print csv with paths to post-print files in S3 to pull those files and store them in a directory'

  task :get_s3_post_prints, [:csv_path, :target_dir] do |_task, args|
    errored_files = []
    CSV.foreach(args[:csv_path], headers: true, encoding: 'ISO8859-1:UTF-8', force_quotes: true, quote_char: '"',
                                 liberal_parsing: true) do |row|
      sys = system("wget --header 'X-API-Key: #{Rails.application.config_for(:activity_insight)['s3_bucket']['api_key']}' 'ai-s3-authorizer.k8s.libraries.psu.edu/api/v1/#{CGI.escape(row['POST_FILE_1_DOC'])}' -P '#{args[:target_dir]}'")
      errored_files << row['POST_FILE_1_DOC'] if sys == false
    end
    puts errored_files
  end
end
