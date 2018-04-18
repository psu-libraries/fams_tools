require 'rest-client'
require 'osp_format'
require 'osp_xml_builder'


namespace :osp_data do

  desc "Clean and filter data from dmresults.csv.
        Write to xls.
        Populate database with data.
        Integrate data into AI."

  task format: :environment do
    start = Time.now
    my_sheet = OspFormat.new
    my_sheet.format
    my_sheet.filter_by_status
    my_sheet.filter_by_date
    my_sheet.filter_by_user
    my_sheet.write_results_to_xl
    my_sheet.csv_hash.each do |row|
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
    finish = Time.now
    puts(((finish - start)/60).to_s + ' mins')
  end

  task integrate: :environment do
    start = Time.now
    my_osp = OspXMLBuilder.new
    auth = {:username => Rails.application.config_for(:activity_insight)[:username], 
            :password => Rails.application.config_for(:activity_insight)[:password]}
    url = 'https://beta.digitalmeasures.com/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-University'
    counter = 0
    max_retries = 3
    my_osp.batched_osp_xml.each do |xml|
      retries = 0
      #puts xml
      begin
        response = HTTParty.post url, :body => xml, :headers => {'Content-type' => 'text/xml'}, :basic_auth => auth
        puts response
      rescue Net::ReadTimeout => e
        if retries < max_retries
          puts 'Retrying'
          retries += 1
          retry
        else
          puts "Exiting script.  Max retries reached."
          exit(1)
        end
      end
      if response.include? 'Error'
        counter += 1
      end
    end
    puts counter
    finish = Time.now
    puts(((finish - start)/60).to_s + ' mins') 
  end
end
