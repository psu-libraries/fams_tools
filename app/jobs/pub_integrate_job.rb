class PubIntegrateJob < ApplicationJob

  def integrate(params, _user_uploaded = true)
    import_pubs = PubData::GetPubData.new(params[:college])
    import_pubs.call(PubData::PubPopulateDb.new)
    my_integrate = ActivityInsight::IntegrateData.new(PubData::PubXmlBuilder.new.xmls_enumerator, params[:target], :post)
    my_integrate.integrate
  end

  private

  def name
    'Publications Integration'
  end
end
