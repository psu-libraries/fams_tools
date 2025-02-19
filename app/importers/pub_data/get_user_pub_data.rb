class PubData::GetUserPubData < PubData::GetPubData
    class MDBError < StandardError; end
    
    def initialize(access_id)
      @user_ids = [access_id]
      super()
    end

  end
  