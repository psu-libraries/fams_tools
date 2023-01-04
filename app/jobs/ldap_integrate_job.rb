class LdapIntegrateJob < ApplicationJob

  def integrate(params, _user_uploaded = true)
    import_ldap = LdapData::ImportLdapData.new
    import_ldap.import_ldap_data
    ldap_integrate = ActivityInsight::IntegrateData.new(LdapData::LdapXmlBuilder.new.xmls_enumerator, params[:target], :post)
    ldap_integrate.integrate
  end

  private

  def name
    'Personal & Contact Info Integration'
  end
end
