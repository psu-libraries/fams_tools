require 'osp_data'

namespace :osp_data do

  my_osp_data = OspData.new

  desc "Clean and filter data from dmresults.csv.
        Write to xls.
        Populate database with data."

  task populate: :environment do
    start = Time.now
    my_osp_data.format_and_filter
    my_osp_data.write
    my_osp_data.populate
    finish = Time.now
    puts(((finish - start)/60).to_s + ' mins') 
  end

  desc "Integrate data into AI through WebServices."

  task integrate: :environment do
    start = Time.now
    my_osp_data.integrate
    finish = Time.now
    puts(((finish - start)/60).to_s + ' mins') 
  end

end
