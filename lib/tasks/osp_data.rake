require 'osp_format'

namespace :osp_data do

  desc "Clean and filter data from dmresults.csv.
        Write to xls.
        Store data in database with appropriate linkages."

  task format: :environment do
    start = Time.now
    my_sheet = OspFormat.new
    my_sheet.format_accessid_field
    my_sheet.format_role_field
    my_sheet.format_date_fields
    my_sheet.format_pending
    my_sheet.format_start_end
    my_sheet.filter_by_date
    my_sheet.remove_columns
    my_sheet.filter_by_user
    my_sheet.write_results_to_xl
    my_sheet.csv_object.each do |row|
      begin
        sponsor = Sponsor.create(sponsor_name: row[2],
                                 sponsor_type: row[3])

      rescue ActiveRecord::RecordNotUnique
        sponsor = Sponsor.find_by(sponsor_name: row[2])
      end

      begin
        contract = Contract.create(osp_key:           row[0],
                                   title:             row[1],
                                   sponsor:           sponsor,
                                   status:            row[10],
                                   submitted:         row[11],
                                   awarded:           row[12],
                                   requested:         row[13],
                                   funded:            row[14],
                                   total_anticipated: row[15],
                                   start_date:        row[16],
                                   end_date:          row[17],
                                   grant_contract:    row[18],
                                   base_agreement:    row[19])

      rescue ActiveRecord::RecordNotUnique
        contract = Contract.find_by(osp_key: row[0])
      end

      begin
        faculty = Faculty.create(access_id: row[4],
                                 f_name:    row[5],
                                 l_name:    row[6],
                                 m_name:    row[7])

      rescue ActiveRecord::RecordNotUnique
        faculty = Faculty.find_by(access_id: row[4])
      end

      ContractFacultyLink.create(contract:   contract,
                                 faculty:    faculty,
                                 role:       row[8],
                                 pct_credit: row[9])

    end
    finish = Time.now
    puts(((finish - start)/60).to_s + ' mins')
  end

  task integrate: :environment do
    start = Time.now
    my_osp = OspMaster.new
    my_osp.build_xml
    finish = Time.now
    puts(((finish - start)/60).to_s + ' mins') 
  end
end
