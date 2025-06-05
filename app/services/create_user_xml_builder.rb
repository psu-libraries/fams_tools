require 'rexml/document'

class CreateUserXmlBuilder
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
    admin_dep.add_element('DEP').text = row['Department'].strip unless row['Department'].to_s.strip.empty?
    admin.add_element('CAMPUS').text = row['Campus'].strip
    admin.add_element('CAMPUS_NAME').text = row['Campus_Name'].strip
    admin.add_element('COLLEGE').text = row['College'].strip
    admin.add_element('COLLEGE_NAME').text = row['College_Name'].strip
    admin.add_element('DIVISION').text = row['Division'].strip unless row['Division'].to_s.strip.empty?
    admin.add_element('DTD_END')
    admin.add_element('DTD_START')
    admin.add_element('DTM_END')
    admin.add_element('DTM_START')
    admin.add_element('DTY_END')
    admin.add_element('DTY_START')
    admin.add_element('ENDPOS')
    admin.add_element('GRADUATE')
    admin.add_element('HR_CODE')
    admin.add_element('INSTITUTE').text = row['Institute'].strip unless row['Institute'].to_s.strip.empty?
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
end
