require 'pure_data/get_pure_data'
  
namespace :pure_data do

  desc "Import pure data to our database"

  task get_data: :environment do

    start = Time.now
    my_get_pure_data = GetPureData.new
    my_get_pure_data.get_by_user
    finish = Time.now
    puts(((finish - start)/60).to_s + ' mins')

  end

end
