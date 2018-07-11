require 'rails_helper'
require 'osp_data/osp_xml_builder'

RSpec.describe OspXMLBuilder do

  let(:data_sets) do
    [{'ospkey' => 123456, 'title' => 'Title', 'status' => 'Pending', 'submitted' => '2016-01-01',
      'awarded' => '', 'requested' => 1000, 'funded' => '', 'totalanticipated' => '', 'startdate' => '',
      'enddate' => '', 'grantcontract' => '', 'baseagreement' => '', 'accessid' => 'aaa111', 'f_name' => 'Bill',
      'l_name' => 'Billy', 'm_name' => 'Billiam', 'sponsor' => 'Sponsor', 'sponsortype' => 'Big Sponsor',
      'role' => 'Principal Investigator', 'pctcredit' => 100, 'userid' => 123, 'notfunded' => '2015-02-01'},
      {'ospkey' => 654321, 'title' => 'Title', 'status' => 'Pending', 'submitted' => '2016-01-01',
      'awarded' => '', 'requested' => 1000, 'funded' => '', 'totalanticipated' => '', 'startdate' => '',
      'enddate' => '', 'grantcontract' => '', 'baseagreement' => '', 'accessid' => 'bbb222', 'f_name' => 'Bill',
      'l_name' => 'Billy', 'm_name' => 'Billiam', 'sponsor' => 'Sponsor2', 'sponsortype' => 'Big Sponsor',
      'role' => 'Principal Investigator', 'pctcredit' => 100, 'userid' => 321, 'notfunded' => '2015-02-01'}]
  end

  let(:osp_xml_builder_obj) {OspXMLBuilder.new}

  describe '#batched_osp_xml' do
    it 'should return an xml of CONGRANT records' do
      data_sets.each do |row|
        sponsor = Sponsor.create(sponsor_name: row['sponsor'],
                                 sponsor_type: row['sponsortype'])

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
                                   base_agreement:    row['baseagreement'],
                                   notfunded:         row['notfunded'])

        faculty = Faculty.create(access_id: row['accessid'],
                                 user_id:   row['userid'],
                                 f_name:    row['f_name'],
                                 l_name:    row['l_name'],
                                 m_name:    row['m_name'])

        ContractFacultyLink.create(contract:   contract,
                                   faculty:    faculty,
                                   role:       row['role'],
                                   pct_credit: row['pctcredit'])

      end
      expect(osp_xml_builder_obj.batched_osp_xml).to eq([
'<?xml version="1.0" encoding="UTF-8"?>
<Data>
  <Record username="aaa111">
    <CONGRANT>
      <OSPKEY access="READ_ONLY">123456</OSPKEY>
      <BASE_AGREE access="READ_ONLY"/>
      <TYPE access="READ_ONLY"/>
      <TITLE access="READ_ONLY">Title</TITLE>
      <SPONORG access="READ_ONLY">Sponsor</SPONORG>
      <AWARDORG access="READ_ONLY">Big Sponsor</AWARDORG>
      <CONGRANT_INVEST>
        <FACULTY_NAME>123</FACULTY_NAME>
        <FNAME>Bill</FNAME>
        <MNAME>Billiam</MNAME>
        <LNAME>Billy</LNAME>
        <ROLE>Principal Investigator</ROLE>
        <ASSIGN>100</ASSIGN>
      </CONGRANT_INVEST>
      <AMOUNT_REQUEST access="READ_ONLY">1000</AMOUNT_REQUEST>
      <AMOUNT_ANTICIPATE access="READ_ONLY"/>
      <AMOUNT access="READ_ONLY"/>
      <STATUS access="READ_ONLY">Pending</STATUS>
      <DTM_SUB access="READ_ONLY">January</DTM_SUB>
      <DTD_SUB access="READ_ONLY">01</DTD_SUB>
      <DTY_SUB access="READ_ONLY">2016</DTY_SUB>
      <DTM_AWARD/>
      <DTD_AWARD/>
      <DTY_AWARD/>
      <DTM_START/>
      <DTD_START/>
      <DTY_START/>
      <DTM_END/>
      <DTD_END/>
      <DTY_END/>
      <DTM_DECLINE access="READ_ONLY">February</DTM_DECLINE>
      <DTD_DECLINE access="READ_ONLY">01</DTD_DECLINE>
      <DTY_DECLINE access="READ_ONLY">2015</DTY_DECLINE>
    </CONGRANT>
  </Record>
  <Record username="bbb222">
    <CONGRANT>
      <OSPKEY access="READ_ONLY">654321</OSPKEY>
      <BASE_AGREE access="READ_ONLY"/>
      <TYPE access="READ_ONLY"/>
      <TITLE access="READ_ONLY">Title</TITLE>
      <SPONORG access="READ_ONLY">Sponsor2</SPONORG>
      <AWARDORG access="READ_ONLY">Big Sponsor</AWARDORG>
      <CONGRANT_INVEST>
        <FACULTY_NAME>321</FACULTY_NAME>
        <FNAME>Bill</FNAME>
        <MNAME>Billiam</MNAME>
        <LNAME>Billy</LNAME>
        <ROLE>Principal Investigator</ROLE>
        <ASSIGN>100</ASSIGN>
      </CONGRANT_INVEST>
      <AMOUNT_REQUEST access="READ_ONLY">1000</AMOUNT_REQUEST>
      <AMOUNT_ANTICIPATE access="READ_ONLY"/>
      <AMOUNT access="READ_ONLY"/>
      <STATUS access="READ_ONLY">Pending</STATUS>
      <DTM_SUB access="READ_ONLY">January</DTM_SUB>
      <DTD_SUB access="READ_ONLY">01</DTD_SUB>
      <DTY_SUB access="READ_ONLY">2016</DTY_SUB>
      <DTM_AWARD/>
      <DTD_AWARD/>
      <DTY_AWARD/>
      <DTM_START/>
      <DTD_START/>
      <DTY_START/>
      <DTM_END/>
      <DTD_END/>
      <DTY_END/>
      <DTM_DECLINE access="READ_ONLY">February</DTM_DECLINE>
      <DTD_DECLINE access="READ_ONLY">01</DTD_DECLINE>
      <DTY_DECLINE access="READ_ONLY">2015</DTY_DECLINE>
    </CONGRANT>
  </Record>
</Data>
'])
        end
      end
    end

