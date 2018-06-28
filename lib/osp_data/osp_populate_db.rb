require 'osp_data/osp_parser'

class OspPopulateDB
  attr_accessor :osp_parser

  def initialize(osp_parser_obj = OspParser.new)
    @osp_parser = osp_parser_obj
  end

  def format_and_filter
    osp_parser.format
    osp_parser.filter_by_status
    osp_parser.filter_by_date
    osp_parser.filter_by_user
  end

  #You'll want to make sure you run #write and #populate
  #after running #format_and_filter in downstream applications
  def write
    osp_parser.write_results_to_xl
  end

  def populate
    osp_parser.xlsx_hash.each do |row|
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

      faculty = Faculty.find_by(access_id: row['accessid'])

      ContractFacultyLink.create(contract:   contract,
                                 faculty:    faculty,
                                 role:       row['role'],
                                 pct_credit: row['pctcredit'])

    end
  end

end

