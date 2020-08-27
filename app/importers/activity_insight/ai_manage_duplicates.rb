#Finds CONGRANT duplicates directly in the system
class ReturnSystemDups
  attr_accessor :username_arr, :responses, :xml_arr, :congrant_hash

  def initialize(usernames = [])
    @username_arr = usernames
    @responses = get_congrant_xmls
  end

  def call
    put_duplicates(xml_to_hash(noko_xml(responses)))
  end

  private

  def get_congrant_xmls
    responses = []
    auth = {:username => Rails.application.config_for(:activity_insight)["webservices"][:username],
            :password => Rails.application.config_for(:activity_insight)["webservices"][:password]}
    username_arr.each do |username|
      url = 'https://betawebservices.digitalmeasures.com/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-University/USERNAME:' + username + '/CONGRANT'
      #url = 'https://webservices.digitalmeasures.com/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-University/USERNAME:' + username + '/CONGRANT'
      responses << (HTTParty.get url, :basic_auth => auth)
    end
    return responses
  end

  def noko_xml(responses)
    xml_arr = []
    responses.each do |response|
      xml_arr << Nokogiri::XML.parse(response.to_s)
    end
    return xml_arr
  end

  def xml_to_hash(xml_arr)
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
    return congrant_hash
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

public

#Note: This uses backup file from DM converted to tab del text to get all CONGRANT data in system.  Does NOT use GET request.
class RemoveSystemDups
  attr_accessor :filepath, :ospkey_hash, :congrant_data, :duplicates_stored, :duplicates_final, :target, :url

  def initialize(filepath = "#{Rails.root}/app/parsing_files/CONGRANT.csv", target)
    @filepath = filepath
    @ospkey_hash = {}
    @duplicates_stored = []
    @duplicates_final = []
    @target = target.to_sym
    @url = get_url(target)
  end

  def call
    grab_duplicates(csv_to_hashes(filepath))
    delete_duplicates(check_local_db(duplicates_stored))
  end

  def write
    grab_duplicates(csv_to_hashes(congrant_data))
    write_to_spreadsheet(check_local_db(duplicates_stored))
  end

  private

  def csv_to_hashes(filepath)
    index = 0
    keys = []
    CSV.foreach(filepath, encoding: "ISO8859-1:UTF-8", force_quotes: true, quote_char: '"', liberal_parsing: true) do |row|
      if index == 0
        keys = row
      else
        hashed = Hash[ keys.zip(row) ]
        if hashed['OSPKEY']
          if ospkey_hash[hashed['USERNAME']]
            ospkey_hash[hashed['USERNAME']] << hashed['OSPKEY']
          else
            ospkey_hash[hashed['USERNAME']] = [hashed['OSPKEY']]
          end
        end
      end
      index += 1
    end
    #keys = congrant_data[0]
    #return congrant_data[1..-1].map {|a| Hash[ keys.zip(a) ] }
  end

  def grab_duplicates(congrant_hashed)
    index = 0
    keys = []
    user_duplicates_hash = {}
    ospkey_hash.each do |k,v|
      if user_duplicates_hash[k]
        user_duplicates_hash[k] << v.select {|e| v.count(e) > 1}.uniq
      else
        user_duplicates_hash[k] = v.select {|e| v.count(e) > 1}.uniq
      end
    end
    CSV.foreach(filepath, encoding: "ISO8859-1:UTF-8", force_quotes: true, quote_char: '"', liberal_parsing: true) do |row|
      if index == 0
        keys = row
      else
        hashed = Hash[ keys.zip(row) ]
        if hashed['OSPKEY']
          if user_duplicates_hash[hashed['USERNAME']].include? hashed['OSPKEY']
            duplicates_stored << [hashed['USERNAME'], hashed['TITLE'], hashed['OSPKEY'], hashed['ID']]
          else
            #puts 'NO DUPLICATES'
          end
        end
      end
      index += 1
    end
  end

  def check_local_db(duplicates_stored)
    Contract.find_each do |contract|
      duplicates_stored.each do |duplicate|
        if contract.osp_key.to_s == duplicate[2]
          duplicates_final << duplicate
        end
      end
    end
    duplicates_final
  end

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
      auth = {:username => Rails.application.config_for(:activity_insight)["webservices"][:username],
              :password => Rails.application.config_for(:activity_insight)["webservices"][:password]}
      url = get_url(target)
      response = HTTParty.post url, :basic_auth => auth, :body => delete_xml, :headers => {'Content-type' => 'text/xml'}, :timeout => 180
      # puts response
    else
      #puts 'No Duplicates'
    end
  end

  def get_url(target)
    case target
    when :beta
      'https://betawebservices.digitalmeasures.com/login/service/v4/SchemaData:delete/INDIVIDUAL-ACTIVITIES-University'
    when :production
      'https://webservices.digitalmeasures.com/login/service/v4/SchemaData:delete/INDIVIDUAL-ACTIVITIES-University'
    end
  end

end
