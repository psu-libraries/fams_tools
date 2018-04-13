namespace :ai_data do

  desc "Grab duplicate records from Activity Insight"

  task get_duplicates: :environment do

    college_arr = ['AA', 'AB', 'AG', 'AL', 'BA', 'BC', 'BK', 'CA',
                   'CM', 'ED', 'EM', 'EN', 'GV', 'HH', 'IST', 'LA',
                   'LW', 'MD', 'NR', 'SC', 'UC', 'UE', 'UL']
    auth = {:username => "psu/aisupport", :password => "hAeqxpAWubq"}
    xml_arr = []
    max_retries = 3
    college_arr.each do |college|
      retries = 0
      #url = 'https://beta.digitalmeasures.com/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-University/COLLEGE:' + college + '/CONGRANT'
      url = 'https://www.digitalmeasures.com/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-University/COLLEGE:' + college + '/CONGRANT'
      begin
        response = HTTParty.get url, :basic_auth => auth
        puts 'Success'
      rescue Net::ReadTimeout => e
        if retries < max_retries
          puts 'Retrying'
          retries += 1
          retry
        else
          puts "Exiting script from GET stage.  Max retries reached."
          exit(1)
        end
      end
      xml = Nokogiri::XML.parse(response.to_s)
      xml_arr << xml
    end

    congrant_hash = {}
    xml_arr.each do |xml|
      xml.xpath('//Data:Record', 'Data' => 'http://www.digitalmeasures.com/schema/data').each do |record|
        congrant_hash[record.attr('username')] = []
        record.xpath('xmlns:CONGRANT').each do |congrant|
          unless congrant.xpath('xmlns:OSPKEY').text == ''
            congrant_hash[record.attr('username')] << [congrant.xpath('xmlns:TITLE').text, congrant.xpath('xmlns:OSPKEY').text, congrant.attr('id')]
          end
        end
      end
    end

    duplicates_final = []
    congrant_hash.each do |k,v|
      ospkey_arr = []
      v.each do |congrant|
        ospkey_arr << congrant[1]
      end
      duplicates = ospkey_arr.select{|e| ospkey_arr.count(e) > 1}.uniq
      if duplicates
        v.each do |congrant| 
          if duplicates.include?(congrant[1])
            duplicates_final << [k, congrant[0], congrant[1], congrant[2]]
          else
            #puts 'NO DUPLICATES'
          end
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
    xml2 = builder.to_xml
    puts xml2
    delete_url = 'https://beta.digitalmeasures.com/login/service/v4/SchemaData:delete/INDIVIDUAL-ACTIVITIES-University'
    retries2 = 0
    max_retries2 = 3
    begin
      response2 = HTTParty.post delete_url, :basic_auth => auth, :body => xml2, :headers => {'Content-type' => 'text/xml'}
      puts 'Success!'
    rescue Net::ReadTimeout => e
      if retries2 < max_retries2
        puts 'Retrying'
        retries2 += 1
        retry
      else
        puts "Exiting script from POST stage.  Max retries reached."
        exit(1)
      end
    end
    puts response2
  end
end
