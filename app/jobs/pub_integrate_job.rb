class PubIntegrateJob < ApplicationJob

  def integrate(params, _file_exist = false)
    import_pubs = GetPubData.new(params[:college])
    import_pubs.call(PubPopulateDB.new)
    my_integrate = IntegrateData.new(PubXMLBuilder.new, params[:target])
    my_integrate.integrate
  end

  private

  def name
    'Publications Integration'
  end
end
