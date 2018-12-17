class LdapXmlBuilder
  def initialize
    @faculties = Faculty.joins(:personal_contact).group('id')
  end

  def batched_xmls
    xml_batches = []
    @faculties.each_slice(20) do |batch|
      xml_batches << build_xml(batch)
    end
    return xml_batches
  end

  private
  def build_xml(batch)
    builder = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
      xml.Data {
        batch.each do |faculty|
          xml.Record('username' => faculty.access_id) {
            xml.PCI {
              (faculty.personal_contact.telephone_number != nil) ? xml.OPHONE1_(faculty.personal_contact.telephone_number.split(' ')[1]) : nil
              (faculty.personal_contact.telephone_number != nil) ? xml.OPHONE2_(faculty.personal_contact.telephone_number.split(' ')[2]) : nil
              (faculty.personal_contact.telephone_number != nil) ? xml.OPHONE3_(faculty.personal_contact.telephone_number.split(' ')[3]) : nil
              (faculty.personal_contact.ps_office_address != nil) ? xml.BUILDING_(faculty.personal_contact.ps_office_address.split(/(\D+)/)[1]&.split('$')&.first&.strip) : nil
              (faculty.personal_contact.ps_office_address != nil) ? xml.ROOMNUM_(faculty.personal_contact.ps_office_address.split(/(\D+)/)[0]&.strip) : nil
              (faculty.personal_contact.ps_research != nil) ? xml.RESEARCH_INTERESTS_(faculty.personal_contact.ps_research&.gsub('$', '; ')) : nil
              (faculty.personal_contact.ps_teaching != nil) ? xml.TEACHING_INTERESTS_(faculty.personal_contact.ps_teaching&.gsub('$', '; ')) : nil
              (faculty.personal_contact.mail != nil) ? xml.EMAIL_(faculty.personal_contact.mail) : nil
              (faculty.personal_contact.personal_web != nil) ? xml.WEBSITE_(faculty.personal_contact.personal_web) : nil
              (faculty.f_name != nil) ? xml.FNAME_(faculty.f_name) : nil
              (faculty.m_name != nil) ? xml.MNAME_(faculty.m_name) : nil
              (faculty.l_name != nil) ? xml.LNAME_(faculty.l_name) : nil
              }
          }
        end
      }
    end
    return builder.to_xml
  end
end
