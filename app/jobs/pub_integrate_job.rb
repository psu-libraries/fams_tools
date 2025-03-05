class PubIntegrateJob < ApplicationJob
  def integrate(params, _user_uploaded = true)
    # Update PubData::GetPubData with proper inheritance
    import_pubs = params[:access_id].present? ? PubData::GetUserPubData.new(params[:access_id]) : PubData::GetCollegePubData.new(params[:college])
    import_pubs.call(PubData::PubPopulateDb.new)
    my_integrate = ActivityInsight::IntegrateData.new(PubData::PubXmlBuilder.new.xmls_enumerator, params[:target],
                                                      :post)
    my_integrate.integrate
  end

  private

  def name
    'Publications Integration'
  end
end
