require 'httparty'

namespace :cron do

  desc 'downloads a backup zip file from AI backups resource'

  task download_backup: :environment do
    auth = { :username => Rails.application.config_for(:activity_insight)["backups_service"][:username],
             :password => Rails.application.config_for(:activity_insight)["backups_service"][:password] }
    response = HTTParty.get 'https://webservices.digitalmeasures.com/login/service/v4/SchemaData:backup/INDIVIDUAL-ACTIVITIES-University', basic_auth: auth
    open("./app/ai_backups/faculty_activities-all_data_#{Date.today}.zip", "wb") do |file|
      file.write(response.body)
    end

    Dir.foreach(Rails.root.join('app', 'ai_backups', filename.to_s).to_s) do |item|
      next if item == '.' or item == '..'
      first_slice = item.gsub('faculty_activities-all_data_', '')
      second_slice = first_slice.gsub('.zip', '')
      file_date = Date.parse(second_slice)
      year_ago = Date.today - 1.year
      if file_date < year_ago
        File.delete(Rails.root.join('app', 'ai_backups', item.to_s).to_s) if File.exist?(Rails.root.join('app', 'ai_backups', item.to_s).to_s)
      end
    end
  end
end