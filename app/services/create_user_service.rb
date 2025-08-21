class CreateUserService
  attr_accessor :target

  require 'csv'
  require 'httparty'
  require 'rake'

  def initialize(target)
    @errors = []
    @target = target
  end

  def create_user
    username = ENV.fetch('FAMS_WEBSERVICES_USERNAME')
    password = ENV.fetch('FAMS_WEBSERVICES_PASSWORD')

    CSV.foreach(csv_path, headers: true) do |row|
      current_user = row['Username'].strip
      user_xml = CreateUserXmlBuilder.create_user_xml(row)
      response1 = send_request(base_uri + '/User', user_xml, username, password)
      log_error(response1)

      metadata_xml = CreateUserXmlBuilder.insert_metadata_xml(row)
      response2 = send_request(base_uri + "/UserSchema/USERNAME:#{current_user}", metadata_xml, username, password)
      log_error(response2)

      faculty_xml = CreateUserXmlBuilder.add_faculty_group_xml(row)
      if faculty_xml
        response3 = send_request(base_uri + "/UserRole/USERNAME:#{current_user}", faculty_xml, username, password)
        log_error(response3)
      end
    end
    FileUtils.rm_f(csv_path)
    @errors
  end

  private

  def log_error(response)
    return unless response.to_s.include?('Error')

    resp_errors = {}
    resp_errors[:response] = response.parsed_response
    @errors << resp_errors
  end

  def send_request(url, xml_data, username, password)
    HTTParty.post(
      url,
      body: xml_data,
      headers: { 'Content-Type' => 'application/xml' },
      basic_auth: { username:, password: }
    )
  end

  def csv_path
    'app/parsing_files/create_user.csv'
  end

  def base_uri
    if target == 'production'
      'https://webservices.digitalmeasures.com/login/service/v4'
    else
      'https://betawebservices.digitalmeasures.com/login/service/v4'
    end
  end
end
