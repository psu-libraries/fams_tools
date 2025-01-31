class LdapCheckJob < ApplicationJob
  def integrate(params, _user_uploaded = true)
    ldap_client = connect_to_central_ldap
    f_path = File.join('app', 'parsing_files', 'check.csv')
    File.binwrite(f_path, params[:ids_file].read)
    puts params
    File.delete(f_path) if File.exist?(f_path)
  end

  private

  def connect_to_central_ldap
    LDAP::NET.new(
      host: 'dirapps.aset.psu.edu',
      port: 389
    )
  end

  def name
    'Ldap Check'
  end
end
