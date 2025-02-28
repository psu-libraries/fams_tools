class PubData::GetCollegePubData < PubData::GetPubData
  class MDBError < StandardError; end

  def initialize(college)
    @user_ids = Faculty.where(college: college.to_s).pluck(:access_id) unless college == 'All Colleges'
    @user_ids = Faculty.pluck(:access_id) if college == 'All Colleges'
    super()
  end
end
