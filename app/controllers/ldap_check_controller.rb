class LdapCheckController < ApplicationController
  def index; end

  def create
    should_disable = params[:ldap_should_disable] == '1'
    data = params[:ldap_check_file]
    result = LdapCheck.new.check(data, should_disable)

    if result[:error]
      flash[:error] = result[:error]
      redirect_to ldap_check_path
    else
      send_data(
        result[:output],
        filename: 'ldap_check_results.csv',
        type: 'text/csv',
        disposition: 'attachment'
      )
    end
  end
end
