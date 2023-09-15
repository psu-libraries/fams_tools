class LdapData::LdapXmlBuilder
  def xmls_enumerator
    Enumerator.new do |i|
      Faculty.joins(:personal_contact).group('id').find_in_batches(batch_size: 20) do |batch|
        i << build_xml(batch)
      end
    end
  end

  private

  def build_xml(batch)
    builder = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
      xml.Data do
        batch.each do |faculty|
          xml.Record('username' => faculty.access_id) do
            xml.PCI do
              faculty.personal_contact.telephone_number.nil? ? nil : xml.OPHONE1_(faculty.personal_contact.telephone_number.split(' ')[1])
              faculty.personal_contact.telephone_number.nil? ? nil : xml.OPHONE2_(faculty.personal_contact.telephone_number.split(' ')[2])
              faculty.personal_contact.telephone_number.nil? ? nil : xml.OPHONE3_(faculty.personal_contact.telephone_number.split(' ')[3])
              faculty.personal_contact.ps_office_address.nil? ? nil : xml.BUILDING_(faculty.personal_contact.ps_office_address.split(/(\D+)/)[1]&.split('$')&.first&.strip)
              faculty.personal_contact.ps_office_address.nil? ? nil : xml.ROOMNUM_(faculty.personal_contact.ps_office_address.split(/(\D+)/)[0]&.strip)
              faculty.personal_contact.ps_research.nil? ? nil : xml.RESEARCH_INTERESTS_(faculty.personal_contact.ps_research&.gsub('$', '; '))
              faculty.personal_contact.ps_teaching.nil? ? nil : xml.TEACHING_INTERESTS_(faculty.personal_contact.ps_teaching&.gsub('$', '; '))
              faculty.personal_contact.mail.nil? ? nil : xml.EMAIL_(faculty.personal_contact.mail)
              faculty.personal_contact.personal_web.nil? ? nil : xml.WEBSITE_(faculty.personal_contact.personal_web)
              faculty.f_name.nil? ? nil : xml.FNAME_(faculty.f_name)
              faculty.m_name.nil? ? nil : xml.MNAME_(faculty.m_name)
              faculty.l_name.nil? ? nil : xml.LNAME_(faculty.l_name)
            end
          end
        end
      end
    end
    builder.to_xml
  end
end
