require 'nokogiri'

class OspXMLBuilder
  def initialize
    @faculties = Faculty.joins(:contract_faculty_links).group('access_id')
  end

  #Chunks osp data into batches so we don't overload AI with records
  def batched_osp_xml
    xml_batches = []
    @faculties.each_slice(20) do |batch|
      xml_batches << build_xml(batch)
    end
    return xml_batches
  end

  private
  #Generates xml from a batch of faculty objects
  def build_xml(batch)
    builder = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
      xml.Data {
        batch.each do |faculty|
          xml.Record('username' => faculty.access_id) {
            faculty.contract_faculty_links.each do |link|
              xml.CONGRANT {
                xml.OSPKEY_ link.contract.osp_key, :access => "LOCKED"
                xml.BASE_AGREE_ link.contract.base_agreement, :access => "LOCKED"
                xml.TYPE_ link.contract.grant_contract, :access => "LOCKED"
                xml.TITLE_ link.contract.title, :access => "LOCKED"
                xml.SPONORG_ link.contract.sponsor.sponsor_name, :access => "LOCKED"
                xml.AWARDORG_ link.contract.sponsor.sponsor_type, :access => "LOCKED"
                xml.CONGRANT_INVEST {
                  xml.FACULTY_NAME_ faculty.user_num.id_number
                  xml.FNAME_ faculty.f_name
                  xml.MNAME_ faculty.m_name
                  xml.LNAME faculty.l_name
                  xml.ROLE_ link.role
                  xml.ASSIGN_ link.pct_credit 
                }
                xml.AMOUNT_REQUEST_ link.contract.requested, :access => "LOCKED"
                xml.AMOUNT_ANTICIPATE_ link.contract.total_anticipated, :access => "LOCKED"
                xml.AMOUNT_ link.contract.funded, :access => "LOCKED"
                xml.STATUS_ link.contract.status, :access => "LOCKED"
                xml.DTM_SUB_ Date.strptime(link.contract.submitted.to_s, '%Y-%m-%d').strftime('%B'), :access => "LOCKED"
                xml.DTD_SUB_ Date.strptime(link.contract.submitted.to_s, '%Y-%m-%d').strftime('%d'), :access => "LOCKED"
                xml.DTY_SUB_ Date.strptime(link.contract.submitted.to_s, '%Y-%m-%d').strftime('%Y'), :access => "LOCKED"
                begin
                  xml.DTM_AWARD_ Date.strptime(link.contract.awarded.to_s, '%Y-%m-%d').strftime('%B'), :access => "LOCKED"
                  xml.DTD_AWARD_ Date.strptime(link.contract.awarded.to_s, '%Y-%m-%d').strftime('%d'), :access => "LOCKED"
                  xml.DTY_AWARD_ Date.strptime(link.contract.awarded.to_s, '%Y-%m-%d').strftime('%Y'), :access => "LOCKED"
                rescue ArgumentError
                  xml.DTM_AWARD_
                  xml.DTD_AWARD_
                  xml.DTY_AWARD_
                end
                begin
                  xml.DTM_START_ Date.strptime(link.contract.start_date.to_s, '%Y-%m-%d').strftime('%B'), :access => "LOCKED"
                  xml.DTD_START_ Date.strptime(link.contract.start_date.to_s, '%Y-%m-%d').strftime('%d'), :access => "LOCKED"
                  xml.DTY_START_ Date.strptime(link.contract.start_date.to_s, '%Y-%m-%d').strftime('%Y'), :access => "LOCKED"
                rescue ArgumentError
                  xml.DTM_START_
                  xml.DTD_START_
                  xml.DTY_START_
                end
                begin
                  xml.DTM_END_ Date.strptime(link.contract.end_date.to_s, '%Y-%m-%d').strftime('%B'), :access => "LOCKED"
                  xml.DTD_END_ Date.strptime(link.contract.end_date.to_s, '%Y-%m-%d').strftime('%d'), :access => "LOCKED"
                  xml.DTY_END_ Date.strptime(link.contract.end_date.to_s, '%Y-%m-%d').strftime('%Y'), :access => "LOCKED"
                rescue ArgumentError
                  xml.DTM_END_
                  xml.DTD_END_
                  xml.DTY_END_
                end
              }
            end
          }
        end
      }
    end
    return builder.to_xml
  end
end
