namespace :osp_data do

  desc "Clean and filter data from dmresults.csv.
        Write to xls.
        Populate database with data."

  task format_and_populate: :environment do
    start = Time.now
    my_populate = OspPopulateDB.new
    my_populate.format_and_filter
    my_populate.write
    my_populate.populate
    finish = Time.now
    puts(((finish - start)/60).to_s + ' mins') 
  end

  desc "Integrate data into AI through WebServices."

  task integrate: :environment do
    start = Time.now
    my_integrate = IntegrateData.new(OspXMLBuilder.new, :beta)
    my_integrate.integrate
    finish = Time.now
    puts(((finish - start)/60).to_s + ' mins') 
  end

end
