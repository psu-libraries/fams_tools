class CreateUserService
  require 'csv'
  require 'net/http'
  require 'uri'
  require 'rexml/document'
  require 'rake'

  def create_user
    api_url = ENV.fetch('FAMS_AI_CREATE_USER_API')  # Ensure this points to the correct API endpoint
    username = ENV.fetch('FAMS_WEBSERVICES_USERNAME')
    password = ENV.fetch('FAMS_WEBSERVICES_PASSWORD')

    CSV.foreach(csv_path, headers: true) do |row|
      xml = create_user_xml(row)
      puts "Generated XML for #{row['Username']}:\n#{xml}"

      response = send_request(api_url, xml, username, password)

    
      case response.code.to_i
      when 200, 201
        if response.body.match?(/<dmu:Success[\s\S]*?>/)
          puts "✅ User #{row['Username']} uploaded successfully!"
        else
          puts "❌ Failed to upload #{row['Username']}: Unexpected success response."
        end
      when 400
        puts "Bad Request: Check data format for #{row['Username']}."
      when 401
        puts "Unauthorized: Check API credentials."
      when 403
        puts "Forbidden: Insufficient permissions."
      when 500
        puts "Server Error: Issue with Activity Insight API."
      else
        puts "❌ Failed to upload #{row['Username']}: #{response.body}"
      end
    end
  end

  def create_user_xml(row)
    doc = REXML::Document.new
    user = doc.add_element("User", { "username" => row['Username'].strip })
  
    user.add_element("FirstName").text = row['First Name'].strip
    user.add_element("LastName").text = row['Last Name'].strip
    user.add_element("MiddleName").text = row['Middle Name/Initial'].strip unless row['Middle Name/Initial'].to_s.strip.empty?
    user.add_element("Email").text = row['Email'].strip
  
    # authentication tag
    user.add_element("ShibbolethAuthentication")  
  
    # Debugging Output (Print XML Before Sending)
    xml_string = StringIO.new
    formatter = REXML::Formatters::Default.new
    formatter.write(doc, xml_string)
  
    final_xml = xml_string.string.gsub(/\n\s*/, "").strip
    puts "Generated XML for #{row['Username']}:\n#{final_xml}"  # Print for debugging
  
    final_xml
  end

  def send_request(url, xml_data, username, password)
    uri = URI.parse(url)
    request = Net::HTTP::Post.new(uri)
    request.basic_auth(username, password)
    request.content_type = "application/xml"
    request.body = xml_data

    # Debugging Output
    puts "Sending request to: #{url}"
    puts "Request Body:\n#{xml_data}"
    puts "Using Credentials: #{username} / (hidden for security)"

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end

    puts "Response Code: #{response.code}"
    puts "Response Body:\n#{response.body}"

    response
  end

  private

  def csv_path
    "#{Rails.root.join('app/parsing_files/upload.csv')}"
  end
end
