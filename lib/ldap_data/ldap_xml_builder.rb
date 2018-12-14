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
              xml.OPHONE1_ faculty.personal_contact.telephone_number.split(' ')[1]
              xml.OPHONE2_ faculty.personal_contact.telephone_number.split(' ')[2]
              xml.OPHONE3_ faculty.personal_contact.telephone_number.split(' ')[3]
              xml.BUILDING_ faculty.personal_contact.ps_office_address.split(/(\D+)/)[1]
              xml.ROOMNUM_ faculty.personal_contact.ps_office_address.split(/(\D+)/)[0]
              xml.RESEARCH_INTERESTS_ faculty.personal_contact.ps_research 
              xml.TEACHING_INTERESTS_ faculty.personal_contact.ps_teaching 
              xml.FNAME_ faculty.f_name
              xml.MNAME_ faculty.m_name
              xml.LNAME_ faculty.l_name
              }
          }
        end
      }
    end
    return builder.to_xml
  end
end
