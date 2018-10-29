require 'pub_data/pub_populate_db'
require 'pub_data/pub_xml_builder'
require 'activity_insight/ai_integrate_data'
  
namespace :pub_data do

  desc "Import pub data to our database"

  task format_and_populate: :environment do

    start = Time.now
    import_pubs = GetPubData.new
    import_pubs.call(PubPopulateDB.new)
    finish = Time.now
    puts(((finish - start)/60).to_s + ' mins')

  end

  desc "Integrate data into AI through WebServices."

  task integrate: :environment do
    start = Time.now
    my_integrate = IntegrateData.new(PubXMLBuilder.new)
    my_integrate.integrate
    finish = Time.now
    puts(((finish - start)/60).to_s + ' mins')
  end

end
