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
        normalized_role = CommitteeRoleNormalizer.normalize(committee['role'])

        faculty.committees.create!(
          student_fname: committee['student_fname'],
          student_lname: committee['student_lname'],
          role: normalized_role,
          role_other_explanation: normalized_role == 'Other' ? committee['role'] : nil,
          thesis_title: committee['title'],
          degree_type: committee['degree_name'],
          type_of_work: map_type_of_work(committee['degree_name'], normalized_role),
          stage_of_completion: determine_completion_stage(
            committee['final_submission_approved_at'],
            committee['submission_status']
          ),
          start_year: extract_year(committee['approval_started_at']),
          completion_year: extract_year(committee['final_submission_approved_at'])
        )
      end

      Rails.logger.info("Imported #{committees_data.length} committees for #{faculty.access_id}")
    end

    def map_type_of_work(degree_name, role = nil)
      return nil if degree_name.blank?

      case degree_name.upcase.strip
      when 'PHD', 'PH.D.', 'DOCTOR OF PHILOSOPHY'
        determine_phd_type(role)
      when 'MS', 'M.S.', 'MASTER OF SCIENCE', 'MA', 'M.A.', 'MASTER OF ARTS'
        determine_masters_type(role)
      when 'UNDERGRADUATE', 'BS', 'BA', 'B.S.', 'B.A.'
        'Undergraduate Research'
      when 'POSTDOC', 'POSTDOCTORAL'
        'Postdoctoral Mentorship'
      when 'HONORS'
        'Honors Thesis'
      else
        if degree_name.downcase.include?('phd') || degree_name.downcase.include?('doctor')
          'Ph.D. Dissertation Committee'
        elsif degree_name.downcase.include?('master')
          "Master's Thesis Committee"
        else
          'Dissertation Committee'
        end
      end
    end

    def determine_phd_type(role)
      case role&.downcase
      when 'advisor', 'chairperson'
        'Ph.D. Dissertation'
      else
        'Ph.D. Dissertation Committee'
      end
    end

    def determine_masters_type(role)
      case role&.downcase
      when 'advisor', 'chairperson'
        "Master's Thesis"
      else
        "Master's Thesis Committee"
      end
    end

    def extract_year(date_string)
      return nil if date_string.blank?

      Date.parse(date_string).year
    rescue ArgumentError
      nil
    end

    def determine_completion_stage(final_submission_approved_at, submission_status)
      return 'Completed' if final_submission_approved_at.present?
      return 'Withdrew' if submission_status&.downcase&.include?('withdrawn')

      'In Process'
    end
  end
end
