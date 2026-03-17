require 'etda/committee_records_client'

module CommitteeData
  class EtdaImporter
    def import_all
      Faculty.find_each do |faculty|
        import_for_faculty(faculty)
      rescue Etda::CommitteeRecordsClient::CommitteeRecordsClientError => e
        Rails.logger.error("Failed to import committees for #{faculty.access_id}: #{e.message}")
      end
    end

    private

    def import_for_faculty(faculty)
      result = Etda::CommitteeRecordsClient.new.faculty_committees(faculty.access_id)
      committees_data = result[:data]['committees']

      committees_data.each do |committee|
        faculty.committees.create!(
          student_fname: committee['student_fname'],
          student_lname: committee['student_lname'],
          # Adding in the normalizer method
          role: CommitteeRoleNormalizer.normalize(committee['role']),
          thesis_title: committee['title'],
          degree_type: committee['degree_name']
        )
      end

      Rails.logger.info("Imported #{committees_data.length} committees for #{faculty.access_id}")
    end
  end
end
