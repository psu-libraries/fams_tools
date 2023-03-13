require 'nokogiri'

class OspData::OspXmlBuilder
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
                xml.OSPKEY_ contract.osp_key, :access => "READ_ONLY" if contract.osp_key
                xml.BASE_AGREE_ contract.base_agreement, :access => "READ_ONLY" if contract.base_agreement
                xml.TYPE_ contract.grant_contract, :access => "READ_ONLY" if contract.grant_contract
                (contract.title.present?) ? xml.TITLE_(link.contract.title.gsub(/[^[:print:]]/,''), :access => "READ_ONLY") : nil
                xml.SPONORG_ contract.sponsor.sponsor_name, :access => "READ_ONLY" if contract.sponsor.sponsor_name
                xml.AWARDORG_ contract.sponsor.sponsor_type, :access => "READ_ONLY" if contract.sponsor.sponsor_type
                xml.AMOUNT_ contract.funded, access: 'READ_ONLY' if contract.funded
                xml.AMOUNT_ANTICIPATE_ contract.total_anticipated, access: 'READ_ONLY' if contract.total_anticipated
                if %w[EM IST MD SC UC UL].include?(faculty.college)
                  xml.ACADEMIC_(contract.effort_academic, access: 'READ_ONLY') if contract.effort_academic && !contract.effort_academic.zero?
                  xml.SUMMER_(contract.effort_summer, access: 'READ_ONLY') if contract.effort_summer && !contract.effort_summer.zero?
                  xml.CALENDAR_(contract.effort_calendar, access: 'READ_ONLY') if contract.effort_calendar && !contract.effort_calendar.zero?
                end
                updated_end_date = false
                if contract.base_agreement.present?
                  ContractFacultyLink.joins(:contract)
                      .where('contract_faculty_links.faculty_id = ? AND contracts.base_agreement = ? AND contracts.osp_key != ?',
                             link.faculty_id, contract.base_agreement, contract.osp_key).order("contracts.osp_key DESC").each_with_index do |amendment, index|
                    amendment_contract = amendment.contract
                    if index == 0
                      updated_end_date = true
                      if amendment_contract.end_date
                        xml.DTM_END_ Date.strptime(amendment_contract.end_date.to_s, '%Y-%m-%d').strftime('%B'), :access => "READ_ONLY"
                        xml.DTD_END_ Date.strptime(amendment_contract.end_date.to_s, '%Y-%m-%d').strftime('%d'), :access => "READ_ONLY"
                        xml.DTY_END_ Date.strptime(amendment_contract.end_date.to_s, '%Y-%m-%d').strftime('%Y'), :access => "READ_ONLY"
                      end
                    end
                    xml.AMENDMENT {
                      xml.OSPKEY_ amendment_contract.osp_key, access: 'READ_ONLY' if amendment_contract.osp_key
                      xml.AMOUNT_ amendment_contract.funded, access: 'READ_ONLY' if amendment_contract.funded
                      xml.AMOUNT_ANTICIPATE_ amendment_contract.total_anticipated, access: 'READ_ONLY' if amendment_contract.total_anticipated
                      if amendment_contract.start_date
                        xml.DTM_START_ Date.strptime(amendment_contract.start_date.to_s, '%Y-%m-%d').strftime('%B'), :access => "READ_ONLY"
                        xml.DTD_START_ Date.strptime(amendment_contract.start_date.to_s, '%Y-%m-%d').strftime('%d'), :access => "READ_ONLY"
                        xml.DTY_START_ Date.strptime(amendment_contract.start_date.to_s, '%Y-%m-%d').strftime('%Y'), :access => "READ_ONLY"
                      end
                      if amendment_contract.end_date
                        xml.DTM_END_ Date.strptime(amendment_contract.end_date.to_s, '%Y-%m-%d').strftime('%B'), :access => "READ_ONLY"
                        xml.DTD_END_ Date.strptime(amendment_contract.end_date.to_s, '%Y-%m-%d').strftime('%d'), :access => "READ_ONLY"
                        xml.DTY_END_ Date.strptime(amendment_contract.end_date.to_s, '%Y-%m-%d').strftime('%Y'), :access => "READ_ONLY"
                      end
                      if amendment_contract.awarded
                        xml.DTM_AWARD_ Date.strptime(amendment_contract.awarded.to_s, '%Y-%m-%d').strftime('%B'), :access => "READ_ONLY"
                        xml.DTD_AWARD_ Date.strptime(amendment_contract.awarded.to_s, '%Y-%m-%d').strftime('%d'), :access => "READ_ONLY"
                        xml.DTY_AWARD_ Date.strptime(amendment_contract.awarded.to_s, '%Y-%m-%d').strftime('%Y'), :access => "READ_ONLY"
                      end
                    }
                    done_link_ids << amendment.id
                  end
                end
                if ["pending", "not funded"].include? contract.status.to_s.downcase
                  xml.CONGRANT_INVEST {
                    xml.FACULTY_NAME_ faculty.user_id
                    xml.FNAME_ faculty.f_name
                    xml.MNAME_ faculty.m_name
                    xml.LNAME faculty.l_name
                    xml.ROLE_ link.role
                    xml.ASSIGN_ link.pct_credit
                  }
                else
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
                end
                xml.AMOUNT_REQUEST_ contract.requested, :access => "READ_ONLY"
                if college_list.include? faculty.college
                  xml.STATUS_ contract.status, :access => "READ_ONLY" if contract.status
                end
                if contract.start_date
                  xml.DTM_START_ Date.strptime(contract.start_date.to_s, '%Y-%m-%d').strftime('%B'), :access => "READ_ONLY"
                  xml.DTD_START_ Date.strptime(contract.start_date.to_s, '%Y-%m-%d').strftime('%d'), :access => "READ_ONLY"
                  xml.DTY_START_ Date.strptime(contract.start_date.to_s, '%Y-%m-%d').strftime('%Y'), :access => "READ_ONLY"
                end
                unless updated_end_date
                  if contract.end_date
                    xml.DTM_END_ Date.strptime(contract.end_date.to_s, '%Y-%m-%d').strftime('%B'), :access => "READ_ONLY"
                    xml.DTD_END_ Date.strptime(contract.end_date.to_s, '%Y-%m-%d').strftime('%d'), :access => "READ_ONLY"
                    xml.DTY_END_ Date.strptime(contract.end_date.to_s, '%Y-%m-%d').strftime('%Y'), :access => "READ_ONLY"
                  end
                end
                if contract.submitted
                  xml.DTM_SUB_ Date.strptime(contract.submitted.to_s, '%Y-%m-%d').strftime('%B'), :access => "READ_ONLY"
                  xml.DTD_SUB_ Date.strptime(contract.submitted.to_s, '%Y-%m-%d').strftime('%d'), :access => "READ_ONLY"
                  xml.DTY_SUB_ Date.strptime(contract.submitted.to_s, '%Y-%m-%d').strftime('%Y'), :access => "READ_ONLY"
                end
                if contract.awarded
                  xml.DTM_AWARD_ Date.strptime(contract.awarded.to_s, '%Y-%m-%d').strftime('%B'), :access => "READ_ONLY"
                  xml.DTD_AWARD_ Date.strptime(contract.awarded.to_s, '%Y-%m-%d').strftime('%d'), :access => "READ_ONLY"
                  xml.DTY_AWARD_ Date.strptime(contract.awarded.to_s, '%Y-%m-%d').strftime('%Y'), :access => "READ_ONLY"
                end
                if contract.notfunded
                  xml.DTM_DECLINE_ Date.strptime(contract.notfunded.to_s, '%Y-%m-%d').strftime('%B'), :access => "READ_ONLY"
                  xml.DTD_DECLINE_ Date.strptime(contract.notfunded.to_s, '%Y-%m-%d').strftime('%d'), :access => "READ_ONLY"
                  xml.DTY_DECLINE_ Date.strptime(contract.notfunded.to_s, '%Y-%m-%d').strftime('%Y'), :access => "READ_ONLY"
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
