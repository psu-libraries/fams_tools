require 'pure_data/pure_populate_db'
  
namespace :pure_data do

  desc "Import pure data to our database"

  task populate_db: :environment do

    start = Time.now
    my_pure_populate_db = PurePopulateDB.new
    my_pure_populate_db.populate
    finish = Time.now
    puts(((finish - start)/60).to_s + ' mins')

  end

end
