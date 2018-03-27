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
            begin
              xml.SUB_START_ Date.strptime(link.contract.submitted.to_s, '%Y-%m-%d').strftime('%B')
            rescue ArgumentError
              xml.SUB_START_
            end
            begin
              xml.AWARD_START_ Date.strptime(link.contract.awarded.to_s, '%Y-%m-%d').strftime('%B')
            rescue ArgumentError
              xml.AWARD_START_
            end
            begin
              xml.START_START_ Date.strptime(link.contract.start_date.to_s, '%Y-%m-%d').strftime('%B')
            rescue ArgumentError
              xml.START_START_
            end
            begin
              xml.END_END_ Date.strptime(link.contract.end_date.to_s, '%Y-%m-%d').strftime('%B')
            rescue ArgumentError => e
              xml.END_END_
            end
          }
        end
        }
      end
      }
    end
    puts builder.to_xml
  end
end
