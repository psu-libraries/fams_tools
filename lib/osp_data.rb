require 'osp_format'
require 'osp_xml_builder'

class OspData
  attr_accessor :osp_data, :osp_xml

  def initialize
    @osp_data = OspFormat.new
    @osp_xml = OspXMLBuilder.new
  end

  def format_and_filter
    osp_data.format
    osp_data.filter_by_status
    osp_data.filter_by_date
    osp_data.filter_by_user
  end

  #You'll want to make sure you run #write and #populate
  #after running #format_and_filter in downstream applications
  def write
    osp_data.write_results_to_xl
  end

  def populate
    osp_data.csv_hash.each do |row|
      begin
        sponsor = Sponsor.create(sponsor_name: row['sponsor'],
                                 sponsor_type: row['sponsortype'])

      rescue ActiveRecord::RecordNotUnique
        sponsor = Sponsor.find_by(sponsor_name: row['sponsor'])
      end

      begin
        contract = Contract.create(osp_key:           row['ospkey'],
                                   title:             row['title'],
                                   sponsor:           sponsor,
                                   status:            row['status'],
                                   submitted:         row['submitted'],
                                   awarded:           row['awarded'],
                                   requested:         row['requested'],
                                   funded:            row['funded'],
                                   total_anticipated: row['totalanticipated'],
                                   start_date:        row['startdate'],
                                   end_date:          row['enddate'],
                                   grant_contract:    row['grantcontract'],
                                   base_agreement:    row['baseagreement'])

      rescue ActiveRecord::RecordNotUnique
        contract = Contract.find_by(osp_key: row['ospkey'])
      end

      begin
        faculty = Faculty.create(access_id: row['accessid'],
                                 f_name:    row['f_name'],
                                 l_name:    row['l_name'],
                                 m_name:    row['m_name'])

      rescue ActiveRecord::RecordNotUnique
        faculty = Faculty.find_by(access_id: row['accessid'])
      end

      ContractFacultyLink.create(contract:   contract,
                                 faculty:    faculty,
                                 role:       row['role'],
                                 pct_credit: row['pctcredit'])

    end
  end

  #Make sure to run #integrate only after #format_and_filter and #populate
  def integrate
    auth = {:username => Rails.application.config_for(:activity_insight)[:username],
            :password => Rails.application.config_for(:activity_insight)[:password]}
    url = 'https://beta.digitalmeasures.com/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-University'
    counter = 0
    osp_xml.batched_osp_xml.each do |xml|
      puts xml
      response = HTTParty.post url, :body => xml, :headers => {'Content-type' => 'text/xml'}, :basic_auth => auth, :timeout => 180
      puts response
      if response.include? 'Error'
        counter += 1
      end
    end
    puts counter
  end

end

