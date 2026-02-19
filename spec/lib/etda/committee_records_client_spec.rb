require 'rails_helper'

Rspec.describe CommitteeRecordsClient do
  
  context"when valid API KEY" do 

    context "when user has committees" do
      it "returns committee member JSON" do
        Etda::CommitteeRecordsClient.new.faculty_committees("abc123")
      end
    end

    context "when user has no committees" do
      it "returns empty" do
        
      end
    end

  
  end

  context"when an unsuccessful response from ETDA e.g, API KEY invalid" do
    it "raises a commitee records client error" do 
      
    end
  end

  context "when an time-out occurs" do
    it "raises a commitee records time-out error with a specific message" do 
      
    end
    
  end
end
 
