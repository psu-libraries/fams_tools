require 'pure/get_pure_ids'
  
namespace :pure do

  desc "Import pure IDs to our database"

  task get_pure_ids: :environment do

    start = Time.now
    my_get_pure_ids = GetPureIDs.new
    my_get_pure_ids.call
    finish = Time.now
    puts(((finish - start)/60).to_s + ' mins')

  end

end

