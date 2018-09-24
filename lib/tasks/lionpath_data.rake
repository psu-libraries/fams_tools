require 'lionpath_data/lionpath_populate_db'
require 'lionpath_data/lionpath_xml_builder'
require 'activity_insight/ai_integrate_data'

namespace :lionpath_data do

  desc "Filter and format LionPath data.
        Write to xls.
        Populate database."

  task format_and_populate: :environment do
    start = Time.now
    my_lionpath_populate = LionPathPopulateDB.new
    my_lionpath_populate.format_and_filter
    my_lionpath_populate.write
    my_lionpath_populate.populate
    finish = Time.now
    puts(((finish - start)/60).to_s + ' mins')
  end

  desc "Integrate data into AI through WebServices."

  task integrate: :environment do
    start = Time.now
    lionpath_integrate = IntegrateData.new(LionPathXMLBuilder.new, :beta)
    lionpath_integrate.integrate
    finish = Time.now
    puts(((finish - start)/60).to_s + ' mins')
  end

end

