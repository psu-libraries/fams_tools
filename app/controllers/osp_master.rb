require 'rest-client'
require 'nokogiri'

class OspMaster < ApplicationController
  def initialize
    @faculties = Faculty.all
  end

  def build_xml
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.Data {
      @faculties.each do |faculty|
        xml.Record( 'username' => faculty.access_id )  {
        faculty.contract_faculty_links.each do |link|
          xml.CONGRANT {
            xml.OSPKEY_ link.contract.osp_key
            xml.BASE_AGREE_ link.contract.base_agreement
            xml.TYPE_ link.contract.grant_contract
            xml.TITLE_ link.contract.title
            xml.SPONORG_ link.contract.sponsor.sponsor_name
            xml.AWARDORG_ link.contract.sponsor.sponsor_type
            xml.CONGRANT_INVEST {
              xml.FACULTY_NAME_
              xml.FNAME_ faculty.f_name
              xml.MNAME_ faculty.m_name
              xml.LNAME_ faculty.l_name
              xml.ROLE_ link.role
              xml.ASSIGN_ link.pct_credit
            }
            xml.AMOUNT_REQUEST_ link.contract.requested
            xml.AMOUNT_ANTICIPATE_ link.contract.total_anticipated
            xml.AMOUNT_ link.contract.funded
            xml.STATUS_ link.contract.status
            xml.DTM_SUB_ Date.strptime(link.contract.submitted.to_s, '%Y-%m-%d').strftime('%B')
            xml.DTD_SUB_ Date.strptime(link.contract.submitted.to_s, '%Y-%m-%d').strftime('%d')
            xml.DTY_SUB_ Date.strptime(link.contract.submitted.to_s, '%Y-%m-%d').strftime('%Y')
            begin
              xml.DTM_AWARD_ Date.strptime(link.contract.awarded.to_s, '%Y-%m-%d').strftime('%B')
              xml.DTD_AWARD_ Date.strptime(link.contract.awarded.to_s, '%Y-%m-%d').strftime('%d')
              xml.DTY_AWARD_ Date.strptime(link.contract.awarded.to_s, '%Y-%m-%d').strftime('%Y')
            rescue ArgumentError
              xml.DTM_AWARD_
              xml.DTD_AWARD_
              xml.DTY_AWARD_
            end
            begin
              xml.DTM_START_ Date.strptime(link.contract.start_date.to_s, '%Y-%m-%d').strftime('%B')
              xml.DTD_START_ Date.strptime(link.contract.start_date.to_s, '%Y-%m-%d').strftime('%d')
              xml.DTY_START_ Date.strptime(link.contract.start_date.to_s, '%Y-%m-%d').strftime('%Y')
            rescue ArgumentError
              xml.DTM_START_
              xml.DTD_START_
              xml.DTY_START_
            end
            begin
              xml.DTM_END_ Date.strptime(link.contract.end_date.to_s, '%Y-%m-%d').strftime('%B')
              xml.DTD_END_ Date.strptime(link.contract.end_date.to_s, '%Y-%m-%d').strftime('%d')
              xml.DTY_END_ Date.strptime(link.contract.end_date.to_s, '%Y-%m-%d').strftime('%Y')
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
