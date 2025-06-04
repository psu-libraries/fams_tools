class CreateUserService
  require 'csv'
  require 'net/http'
  require 'uri'
  require 'rexml/document'
  require 'rake'

  def create_user
    api_uri = ENV.fetch('FAMS_WEBSERVICES_BASE_URI', 'https://betawebservices.digitalmeasures.com/login/service/v4')  # Ensure this points to the correct API endpoint
    username = ENV.fetch('FAMS_WEBSERVICES_USERNAME')
    password = ENV.fetch('FAMS_WEBSERVICES_PASSWORD')

    CSV.foreach(csv_path, headers: true) do |row|
      current_user = row['Username'].parse
      user_xml = create_user_xml(row)
      response1 = send_request(api_uri + '/User', user_xml, username, password)
      next unless successful_response?(response1, current_user, 'User')

      metadata_xml = insert_metadata_xml(row)
      response2 = send_request(api_uri + "/UserSchema/USERNAME:#{current_user}", metadata_xml, username, password)
      next unless successful_response?(response2, current_user, 'UserSchema')

      faculty_xml = add_faculty_group_xml(row)
      if faculty_xml
        response3 = send_request(api_uri + "/UserRole/USERNAME:#{current_user}", faculty_xml, username, password)
        next unless successful_response?(response3, current_user, 'UserRole')
      end

      Rails.logger.debug { "✅ All steps completed successfully for #{current_user}" }
    end
  end

  def successful_response?(response, username, step_label)
    case response.code.to_i
    when 200, 201
      if response.body.match?(/<dmu:Success[\s\S]*?>/)
        Rails.logger.debug { "✅ #{step_label} step for #{username} success." }
        true
      else
        Rails.logger.debug { "❌ #{step_label} step for #{username}: Unexpected success response." }
        false
      end
    when 400
      Rails.logger.debug { "❌ #{step_label} step for #{username}: Bad Request - Check data format." }
      false
    when 401
      Rails.logger.debug { "❌ #{step_label} step for #{username}: Unauthorized - Check API credentials." }
      false
    when 403
      Rails.logger.debug { "❌ #{step_label} step for #{username}: Forbidden - Insufficient permissions." }
      false
    when 500
      Rails.logger.debug { "❌ #{step_label} step for #{username}: Server Error - Issue with Activity Insight API." }
      false
    else
      Rails.logger.debug { "❌ #{step_label} step for #{username}: Failed to upload user with #{response.body}" }
      false
    end
  end

  def create_user_xml(row)
    doc = REXML::Document.new
    user = doc.add_element('User', { 'username' => row['Username'].strip })

    user.add_element('FirstName').text = row['First Name'].strip
    user.add_element('LastName').text = row['Last Name'].strip
    user.add_element('MiddleName').text = row['Middle Name/Initial'].strip unless row['Middle Name/Initial'].to_s.strip.empty?
    user.add_element('Email').text = row['Email'].strip

    # authentication tag
    user.add_element('ShibbolethAuthentication')

    # Debugging Output (Print XML Before Sending)
    xml_string = StringIO.new
    formatter = REXML::Formatters::Default.new
    formatter.write(doc, xml_string)

    final_xml = xml_string.string.gsub(/\n\s*/, '').strip
    Rails.logger.debug { "Generated user XML for #{row['Username']}:\n#{final_xml}" } # Print for debugging

    final_xml
  end

  def insert_metadata_xml(row)
    doc = REXML::Document.new

    # Outer layer to add user to schema
    activities = doc.add_element('INDIVIDUAL-ACTIVITIES-University')

    # Inner layer to add metadata
    admin = activities.add_element('ADMIN')

    # Metadata
    admin.add_element('AC_YEAR').text = '2025-2026'
    admin_dep = admin.add_element('ADMIN_DEP')
    admin_dep.add_element('DEP').text = row['Department'].strip
    admin.add_element('CAMPUS').text = row['Campus'].strip
    admin.add_element('CAMPUS_NAME').text = row['Campus_Name'].strip
    admin.add_element('COLLEGE').text = row['College'].strip
    admin.add_element('COLLEGE_NAME').text = row['College_Name'].strip
    admin.add_element('DIVISION').text = row['Division'].strip
    admin.add_element('DTD_END')
    admin.add_element('DTD_START')
    admin.add_element('DTM_END')
    admin.add_element('DTM_START')
    admin.add_element('DTY_END')
    admin.add_element('DTY_START')
    admin.add_element('END_POS')
    admin.add_element('GRADUATE')
    admin.add_element('HR_CODE')
    admin.add_element('INSTITUTE').text = row['Institute'].strip
    admin.add_element('LEAVE')
    admin.add_element('LEAVE_OTHER')
    admin.add_element('RANK')
    admin.add_element('RESULT_SABB')
    admin.add_element('SCHOOL')
    admin.add_element('TENURE')
    admin.add_element('TIME_STATUS')
    admin.add_element('TITLE')

    # Debugging Output (Print XML Before Sending)
    xml_string = StringIO.new
    formatter = REXML::Formatters::Default.new
    formatter.write(doc, xml_string)

    final_xml = xml_string.string.gsub(/\n\s*/, '').strip
    Rails.logger.debug { "Generated metadata XML for #{row['Username']}:\n#{final_xml}" } # Print for debugging

    final_xml
  end

  def add_faculty_group_xml(row)
    doc = REXML::Document.new
    return nil if row['Security'] != 'Faculty'

    doc.add_element('INDIVIDUAL-ACTIVITIES-University-Faculty')

    xml_string = StringIO.new
    formatter = REXML::Formatters::Default.new
    formatter.write(doc, xml_string)

    final_xml = xml_string.string.gsub(/\n\s*/, '').strip
    Rails.logger.debug { "Generated role XML for #{row['Username']}:\n#{final_xml}" } # Print for debugging
    final_xml
  end

  def send_request(url, xml_data, username, password)
    uri = URI.parse(url)
    request = Net::HTTP::Post.new(uri)
    request.basic_auth(username, password)
    request.content_type = 'application/xml'
    request.body = xml_data

    # Debugging Output
    Rails.logger.debug { "Sending request to: #{url}" }
    Rails.logger.debug { "Request Body:\n#{xml_data}" }
    Rails.logger.debug { "Using Credentials: #{username} / (hidden for security)" }

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end

    Rails.logger.debug { "Response Code: #{response.code}" }
    Rails.logger.debug { "Response Body:\n#{response.body}" }

    response
  end

  private

  def csv_path
    Rails.root.join('app/parsing_files/upload.csv').to_s
  end
end
