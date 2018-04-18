namespace :ai_data do

  desc "Grab duplicate records from Activity Insight"

  task get_duplicates: :environment do

    congrant_data = CSV.read('data/CONGRANT-tabdel.txt', encoding: "ISO8859-1", col_sep: "\t")
    keys = congrant_data[0]
    congrant_hash = congrant_data[1..-1].map {|a| Hash[ keys.zip(a) ] }

    duplicates_final = []
    ospkey_hash = {}
    congrant_hash.each do |congrant|
      if congrant['OSPKEY']
        if ospkey_hash[congrant['USERNAME']]
          ospkey_hash[congrant['USERNAME']] << congrant['OSPKEY']
        else
          ospkey_hash[congrant['USERNAME']] = [congrant['OSPKEY']]
        end
      end
    end
    user_duplicates_hash = {}
    ospkey_hash.each do |k,v|
      if user_duplicates_hash[k]
        user_duplicates_hash[k] << v.select {|e| v.count(e) > 1}.uniq
      else
        user_duplicates_hash[k] = v.select {|e| v.count(e) > 1}.uniq
      end
    end
    congrant_hash.each do |congrant| 
      if congrant['OSPKEY']
        if user_duplicates_hash[congrant['USERNAME']].include? congrant['OSPKEY']
          duplicates_final << [congrant['USERNAME'], congrant['TITLE'], congrant['OSPKEY'], congrant['ID']]
        else
          #puts 'NO DUPLICATES'
        end
      end
    end

    wb = Spreadsheet::Workbook.new 'data/duplicates.xls'
    sheet = wb.create_worksheet
    head_arr = ['username', 'title', 'ospkey', 'id']
    head_arr.each do |head|
      sheet.row(0).push(head)
    end
    duplicates_final.each_with_index do |item, index|
      item.each do |v|
        sheet.row(index+1).push(v)
      end
    end
    wb.write 'data/duplicates.xls'

    builder = Nokogiri::XML::Builder.new do |xml|
      xml.Data {
	xml.CONGRANT {
          duplicates_final.each do |duplicate|
            xml.item( 'id' => duplicate[3] )
          end
        }
       }
    end
    delete_xml = builder.to_xml
    puts delete_xml
    auth = {:username => Rails.application.config_for(:activity_insight)[:username], 
            :password => Rails.application.config_for(:activity_insight)[:password]}
    url = 'https://beta.digitalmeasures.com/login/service/v4/SchemaData:delete/INDIVIDUAL-ACTIVITIES-University'
    retries = 0
    max_retries = 3
    begin
      response = HTTParty.post url, :basic_auth => auth, :body => delete_xml, :headers => {'Content-type' => 'text/xml'}
      puts 'Success!'
    rescue Net::ReadTimeout => e
      if retries < max_retries
        puts 'Retrying'
        retries += 1
        retry
      else
        puts "Exiting script from POST stage.  Max retries reached."
        exit(1)
      end
    end
    puts response
  end
end
