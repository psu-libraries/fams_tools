require 'pure_data/pure_populate_db'
require 'pure_data/pure_xml_builder'
require 'activity_insight/ai_integrate_data'
  
namespace :pure_data do

  desc "Import pure data to our database"

  task populate_db: :environment do

    start = Time.now
    my_pure_populate_db = PurePopulateDB.new
    my_pure_populate_db.populate
    finish = Time.now
    puts(((finish - start)/60).to_s + ' mins')

  end

   desc "Integrate data into AI through WebServices."

  task integrate: :environment do
    start = Time.now
    my_integrate = IntegrateData.new(PureXMLBuilder.new)
    my_integrate.integrate
    finish = Time.now
    puts(((finish - start)/60).to_s + ' mins')
  end

end
