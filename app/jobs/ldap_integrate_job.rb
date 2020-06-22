class LdapIntegrateJob < ApplicationJob

  def integrate(params)
    import_ldap = ImportLdapData.new
    import_ldap.import_ldap_data
    ldap_integrate = IntegrateData.new(LdapXmlBuilder.new, params[:target])
    ldap_integrate.integrate
  end

  private

  def name
    'Personal & Contact Info Integration'
  end
end
