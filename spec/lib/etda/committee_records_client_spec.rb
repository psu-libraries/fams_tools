require 'rails_helper'
require 'etda/committee_records_client'

RSpec.describe Etda::CommitteeRecordsClient do
  let(:client) { Etda::CommitteeRecordsClient.new }
  let(:url) { 'http://localhost:3000/api/v1/committee_records/faculty_committees' }

  context "when valid API KEY" do

    context "when user has committees" do
      it "returns committee member JSON" do
        stub_request(:post, url)
          .to_return(
            status: 200,
            body: {
              faculty_access_id: 'abc123',
              committees: [
                {
                  role: 'Advisor',
                  student_fname: 'John',
                  student_lname: 'Doe',
                  title: 'Machine Learning in Healthcare',
                  degree_name: 'PhD'
                }
              ]
            }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )

        result = client.faculty_committees("abc123")

        expect(result[:success]).to eq(true)
        expect(result[:data]['committees'].length).to eq(1)
      end
    end

    context "when user has no committees" do
      it "returns empty" do
        stub_request(:post, url)
          .to_return(
            status: 200,
            body: {
              faculty_access_id: 'abc123',
              committees: []
            }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )

        result = client.faculty_committees("abc123")

        expect(result[:success]).to eq(true)
        expect(result[:data]['committees']).to be_empty
      end
    end


  end

  context "when an unsuccessful response from ETDA e.g, API KEY invalid" do
    it "raises a commitee records client error" do
      stub_request(:post, url)
        .to_return(
          status: 401,
          body: { error: 'Unauthorized' }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      expect { client.faculty_committees("abc123") }
        .to raise_error(Etda::CommitteeRecordsClient::CommitteeRecordsClientError)
    end
  end

  context "when an time-out occurs" do
    it "raises a commitee records time-out error with a specific message" do
      stub_request(:post, url).to_raise(Net::OpenTimeout)

      expect { client.faculty_committees("abc123") }
        .to raise_error(Etda::CommitteeRecordsClient::CommitteeRecordsClientError)
    end

  end
end
