namespace :pub_data do
  desc 'Import pub data to our database'

  task format_and_populate: :environment do
    start = Time.now
    import_pubs = PubData::GetPubData.new
    import_pubs.call(PubData::PubPopulateDb.new)
    finish = Time.now
    puts(((finish - start) / 60).to_s + ' mins')
  end

  desc 'Integrate data into AI through WebServices.'

  task integrate: :environment do
    start = Time.now
    my_integrate = ActivityInsight::IntegrateData.new(PubData::PubXMLBuilder.new)
    my_integrate.integrate
    finish = Time.now
    puts(((finish - start) / 60).to_s + ' mins')
  end
end
