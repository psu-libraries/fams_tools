class LdapIntegrateJob < ApplicationJob

  def integrate(params, _file_exist = false)
    import_ldap = ImportLdapData.new
    import_ldap.import_ldap_data
    ldap_integrate = IntegrateData.new(LdapXmlBuilder.new.xmls_enumerator, params[:target], :post)
    ldap_integrate.integrate
  end

  private

  def name
    'Personal & Contact Info Integration'
  end
end
