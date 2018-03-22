require 'rest-client'
require 'nokogiri'

class OspMaster < ApplicationController
  def initialize
    @contract_faculty_links = ContractFacultyLink.all
  end

  def hash_to_xml
    master_hash = {}
    @contract_faculty_links.each do |link|
      record_hash = {}
      link.contract.attributes.each do |k, v|
        record_hash[k] = v
      end
      link.contract.sponsor.attributes.each do |k, v|
        record_hash[k] = v
      end
      link.faculty.attributes.each do |k, v|
        record_hash[k] = v
      end
      master_hash[link.faculty.access_id] = record_hash
    end
    master_hash.each do |k, v|
      builder = Nokogiri::XML::Builder.new do |xml|
        xml.data {
          xml.record('username' => k) {           
            v.each do |key, value|
              #finish building xml 
          }
        }
      }
    end
    puts builder.to_xml
  end
end
