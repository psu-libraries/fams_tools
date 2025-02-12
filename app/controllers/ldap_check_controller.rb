class LdapCheckController < ApplicationController
  def index; end

  def create
    should_disable = params['ldap_should_disable'] == '1'
    ldap_check = LdapCheck.new(params[:ldap_check_file], should_disable)
    result = ldap_check.perform

    if result[:error]
      flash_error(result[:error])
    else
      send_data(
        result[:output],
        filename: 'ldap_check_results.csv',
        type: 'text/csv',
        disposition: 'attachment'
      )
    end
  end

  private

  def flash_error(msg)
    flash[:error] = msg
    redirect_to ldap_check_path
  end
end