require 'pure_data/pure_populate_db'
require 'pure_data/get_pure_publishers'
require 'pure_data/pure_xml_builder'
require 'activity_insight/ai_integrate_data'
  
namespace :pure_data do

  desc "Import pure data to our database"

  task format_and_populate: :environment do

    start = Time.now
    my_get_pure_ids = GetPureIDs.new
    my_get_pure_ids.call
    my_pure_populate_db = PurePopulateDB.new
    my_pure_populate_db.populate
    my_get_pure_publishers = GetPurePublishers.new
    my_get_pure_publishers.call
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
