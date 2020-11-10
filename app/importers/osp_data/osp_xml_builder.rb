require 'nokogiri'

class OspXMLBuilder
  #Chunks osp data into batches so we don't overload AI with records
  def xmls_enumerator
    Enumerator.new do |i|
      Faculty.joins(:contract_faculty_links).group('id').find_in_batches(batch_size: 20) do |batch|
        i << build_xml(batch)
      end
    end
  end

  private
  #Generates xml from a batch of faculty objects
  def build_xml(batch)
    builder = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
      xml.Data {
        batch.each do |faculty|
          xml.Record('username' => faculty.access_id) {
            done_link_ids = []
            faculty.contract_faculty_links.order("contract_id ASC").each do |link|
              next if done_link_ids.include? link.id

              xml.CONGRANT {
                contract = link.contract
                xml.OSPKEY_ contract.osp_key, :access => "READ_ONLY"
                xml.BASE_AGREE_ contract.base_agreement, :access => "READ_ONLY"
                xml.TYPE_ contract.grant_contract, :access => "READ_ONLY"
                (contract.title.present?) ? xml.TITLE_(link.contract.title.gsub(/[^[:print:]]/,''), :access => "READ_ONLY") : nil
                xml.SPONORG_ contract.sponsor.sponsor_name, :access => "READ_ONLY"
                xml.AWARDORG_ contract.sponsor.sponsor_type, :access => "READ_ONLY"
                xml.AMOUNT_ contract.funded, access: 'READ_ONLY'
                xml.AMOUNT_ANTICIPATE_ contract.total_anticipated, access: 'READ_ONLY'
                if contract.base_agreement.present?
                  ContractFacultyLink.joins(:contract)
                      .where('contract_faculty_links.faculty_id = ? AND contracts.base_agreement = ? AND contracts.osp_key != ?',
                             link.faculty_id, contract.base_agreement, contract.osp_key).order("contracts.osp_key DESC").each do |amendment|
                    xml.AMENDMENT {
                      amendment_contract = amendment.contract
                      xml.OSPKEY_ amendment_contract.osp_key, access: 'READ_ONLY'
                      xml.AMOUNT_ amendment_contract.funded, access: 'READ_ONLY'
                      xml.AMOUNT_ANTICIPATE_ amendment_contract.total_anticipated, access: 'READ_ONLY'
                      begin
                        xml.DTM_START_ Date.strptime(amendment_contract.start_date.to_s, '%Y-%m-%d').strftime('%B'), :access => "READ_ONLY"
                        xml.DTD_START_ Date.strptime(amendment_contract.start_date.to_s, '%Y-%m-%d').strftime('%d'), :access => "READ_ONLY"
                        xml.DTY_START_ Date.strptime(amendment_contract.start_date.to_s, '%Y-%m-%d').strftime('%Y'), :access => "READ_ONLY"
                      rescue ArgumentError
                        xml.DTM_START_
                        xml.DTD_START_
                        xml.DTY_START_
                      end
                      begin
                        xml.DTM_END_ Date.strptime(amendment_contract.end_date.to_s, '%Y-%m-%d').strftime('%B'), :access => "READ_ONLY"
                        xml.DTD_END_ Date.strptime(amendment_contract.end_date.to_s, '%Y-%m-%d').strftime('%d'), :access => "READ_ONLY"
                        xml.DTY_END_ Date.strptime(amendment_contract.end_date.to_s, '%Y-%m-%d').strftime('%Y'), :access => "READ_ONLY"
                      rescue ArgumentError
                        xml.DTM_END_
                        xml.DTD_END_
                        xml.DTY_END_
                      end
                      begin
                        xml.DTM_AWARD_ Date.strptime(amendment_contract.awarded.to_s, '%Y-%m-%d').strftime('%B'), :access => "READ_ONLY"
                        xml.DTD_AWARD_ Date.strptime(amendment_contract.awarded.to_s, '%Y-%m-%d').strftime('%d'), :access => "READ_ONLY"
                        xml.DTY_AWARD_ Date.strptime(amendment_contract.awarded.to_s, '%Y-%m-%d').strftime('%Y'), :access => "READ_ONLY"
                      rescue ArgumentError
                        xml.DTM_AWARD_
                        xml.DTD_AWARD_
                        xml.DTY_AWARD_
                      end
                    }
                    done_link_ids << amendment.id
                  end
                end
                contract.contract_faculty_links.each do |contract_link|
                  linked_faculty = contract_link.faculty
                  xml.CONGRANT_INVEST {
                    xml.FACULTY_NAME_ linked_faculty.user_id
                    xml.FNAME_ linked_faculty.f_name
                    xml.MNAME_ linked_faculty.m_name
                    xml.LNAME linked_faculty.l_name
                    xml.ROLE_ contract_link.role
                    xml.ASSIGN_ contract_link.pct_credit
                  }
                end
                xml.AMOUNT_REQUEST_ contract.requested, :access => "READ_ONLY"
                if college_list.include? faculty.college
                  xml.STATUS_ contract.status, :access => "READ_ONLY"
                end
                begin
                  xml.DTM_START_ Date.strptime(contract.start_date.to_s, '%Y-%m-%d').strftime('%B'), :access => "READ_ONLY"
                  xml.DTD_START_ Date.strptime(contract.start_date.to_s, '%Y-%m-%d').strftime('%d'), :access => "READ_ONLY"
                  xml.DTY_START_ Date.strptime(contract.start_date.to_s, '%Y-%m-%d').strftime('%Y'), :access => "READ_ONLY"
                rescue ArgumentError
                  xml.DTM_START_
                  xml.DTD_START_
                  xml.DTY_START_
                end
                begin
                  xml.DTM_END_ Date.strptime(contract.end_date.to_s, '%Y-%m-%d').strftime('%B'), :access => "READ_ONLY"
                  xml.DTD_END_ Date.strptime(contract.end_date.to_s, '%Y-%m-%d').strftime('%d'), :access => "READ_ONLY"
                  xml.DTY_END_ Date.strptime(contract.end_date.to_s, '%Y-%m-%d').strftime('%Y'), :access => "READ_ONLY"
                rescue ArgumentError
                  xml.DTM_END_
                  xml.DTD_END_
                  xml.DTY_END_
                end
                begin
                  xml.DTM_SUB_ Date.strptime(contract.submitted.to_s, '%Y-%m-%d').strftime('%B'), :access => "READ_ONLY"
                  xml.DTD_SUB_ Date.strptime(contract.submitted.to_s, '%Y-%m-%d').strftime('%d'), :access => "READ_ONLY"
                  xml.DTY_SUB_ Date.strptime(contract.submitted.to_s, '%Y-%m-%d').strftime('%Y'), :access => "READ_ONLY"
                rescue ArgumentError
                  xml.DTM_SUB_
                  xml.DTD_SUB_
                  xml.DTY_SUB_
                end
                begin
                  xml.DTM_AWARD_ Date.strptime(contract.awarded.to_s, '%Y-%m-%d').strftime('%B'), :access => "READ_ONLY"
                  xml.DTD_AWARD_ Date.strptime(contract.awarded.to_s, '%Y-%m-%d').strftime('%d'), :access => "READ_ONLY"
                  xml.DTY_AWARD_ Date.strptime(contract.awarded.to_s, '%Y-%m-%d').strftime('%Y'), :access => "READ_ONLY"
                rescue ArgumentError
                  xml.DTM_AWARD_
                  xml.DTD_AWARD_
                  xml.DTY_AWARD_
                end
                begin
                  xml.DTM_DECLINE_ Date.strptime(contract.notfunded.to_s, '%Y-%m-%d').strftime('%B'), :access => "READ_ONLY"
                  xml.DTD_DECLINE_ Date.strptime(contract.notfunded.to_s, '%Y-%m-%d').strftime('%d'), :access => "READ_ONLY"
                  xml.DTY_DECLINE_ Date.strptime(contract.notfunded.to_s, '%Y-%m-%d').strftime('%Y'), :access => "READ_ONLY"
                rescue ArgumentError
                  xml.DTM_DECLINE_
                  xml.DTD_DECLINE_
                  xml.DTY_DECLINE_
                end
              }
            end
          }
        end
      }
    end
    return builder.to_xml
  end

  def college_list
    ['AG', 'ED', 'CA', 'LA', 'BK', 'SC', 'AA', 'UL', 'BA', 'BC', 'CM', 'LW', 'EM', 'GV', 'HH', 'IST', 'MD', 'NR', 'UC', 'AB', 'AL', 'UE', 'EN']
  end

end
