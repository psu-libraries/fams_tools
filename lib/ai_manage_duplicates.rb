#Finds CONGRANT duplicate directly in the system
class ReturnSystemDups
  attr_accessor :username_arr, :xml_arr, :congrant_hash

  def initialize(usernames = [])
    @username_arr = usernames
    @xml_arr = []
    @congrant_hash = {}
  end

  def call
    get_congrant_xmls
    xml_to_hash(xml_arr)
    put_duplicates(congrant_hash)
  end

  def get_congrant_xmls
    auth = {:username => Rails.application.config_for(:activity_insight)[:username],
            :password => Rails.application.config_for(:activity_insight)[:password]}
    username_arr.each do |username|
      url = 'https://beta.digitalmeasures.com/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-University/USERNAME:' + username + '/CONGRANT'
      #url = 'https://www.digitalmeasures.com/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-University/USERNAME:' + username + '/CONGRANT'
      response = HTTParty.get url, :basic_auth => auth
      #puts response
      xml = Nokogiri::XML.parse(response.to_s)
      xml_arr << xml
    end
  end

  def xml_to_hash(xml_arr)
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
  end

  def put_duplicates(congrant_hash)
    congrant_hash.each do |k, v|
      ospkeys = []
      v.each do |congrant|
        ospkeys << congrant[1]
      end
      puts k
      puts ospkeys.select{|e| ospkeys.count(e) > 1}.uniq
    end
  end

end


#The final methods of this module are used to find duplicates in ai using a backup and removing those duplicates from beta or production
#Converts backup CONGRANT csv to array of hashes
def csv_to_hashes
  congrant_data = CSV.read('data/CONGRANT-tabdel.txt', encoding: "ISO8859-1", col_sep: "\t")
  keys = congrant_data[0]
  congrant_hashed = congrant_data[1..-1].map {|a| Hash[ keys.zip(a) ] }
end

#Returns array of arrays of duplicate information
def grab_duplicates(congrant_hashed)
  duplicates_final = []
  duplicates_stored = []
  ospkey_hash = {}
  congrant_hashed.each do |congrant|
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
  congrant_hashed.each do |congrant|
    if congrant['OSPKEY']
      if user_duplicates_hash[congrant['USERNAME']].include? congrant['OSPKEY']
	duplicates_stored << [congrant['USERNAME'], congrant['TITLE'], congrant['OSPKEY'], congrant['ID']]
      else
	#puts 'NO DUPLICATES'
      end
    end
  end
  Contract.all.each do |contract|
    duplicates_stored.each do |duplicate|
      if contract.osp_key.to_s == duplicate[2]
        duplicates_final << duplicate
      end
    end
  end
  duplicates_final
end

#Writes duplicate information to spreadsheet
def write_to_spreadsheet(duplicates_final)
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
end

#Deletes duplicates from AI using POST request
def delete_duplicates(duplicates_final)
  if duplicates_final
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
    response = HTTParty.post url, :basic_auth => auth, :body => delete_xml, :headers => {'Content-type' => 'text/xml'}, :timeout => 180
    puts response
  else
    puts 'No Duplicates'
  end
end

