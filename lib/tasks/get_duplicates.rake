namespace :ai_data do

  desc "Grab duplicate records from Activity Insight"

  task get_duplicates: :environment do
    college_arr = ['AA', 'AB', 'AG', 'AL', 'BA', 'BC', 'BK', 'CA', 'CM', 'ED',
                   'EM', 'EN', 'GV', 'HH', 'IST', 'LA', 'LW', 'MD', 'NR', 'SC',
                   'UC', 'UE', 'UL']
    auth = {:username => "psu/aisupport", :password => "hAeqxpAWubq"}
    xml_arr = []
    college_arr[0..1].each do |college|
      url = 'https://beta.digitalmeasures.com/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-University/COLLEGE:' + college + '/CONGRANT'
      response = HTTParty.get url, :basic_auth => auth
      #puts response
      xml = Nokogiri::XML.parse(response.to_s)
      xml_arr << xml
    end
    congrant_hash = {}
    xml_arr[0].xpath('//Data:Record', 'Data' => 'http://www.digitalmeasures.com/schema/data').each do |record|
      record.xpath('xmlns:CONGRANT').each  do |congrant|
        unless congrant.xpath('xmlns:OSPKEY').text == ''
          congrant_hash[congrant.xpath('xmlns:OSPKEY').text] << [congrant.xpath('xmlns:TITLE').text, record.attr('username')]
        end
      end
    end
    puts congrant_hash
  end
end
