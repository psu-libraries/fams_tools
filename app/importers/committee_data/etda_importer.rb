require 'etda/committee_records_client'

module CommitteeData
  class EtdaImporter
    class DegreeTypeError < RuntimeError; end

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
        next unless within_last_six_months?(committee['approval_started_at'])

        normalized_role = CommitteeRoleNormalizer.normalize(committee['role'])

        faculty.committees.create!(
          student_fname: committee['student_fname'],
          student_lname: committee['student_lname'],
          role: normalized_role,
          thesis_title: committee['title'],
          type_of_work: map_type_of_work(committee['degree_type']),
          stage_of_completion: determine_completion_stage(
            committee['final_submission_approved_at']
          ),
          start_year: extract_year(committee['approval_started_at']),
          start_month: extract_month(committee['approval_started_at']),
          completion_year: extract_year(committee['final_submission_approved_at']),
          completion_month: extract_month(committee['final_submission_approved_at'])
        )
      end

      Rails.logger.info("Imported #{committees_data.length} committees for #{faculty.access_id}")
    end

    def map_type_of_work(degree_type)
      return nil if degree_type.blank?

      case degree_type.strip
      when 'Master Thesis'
        "Master's Committee"
      when 'Dissertation'
        'Dissertation Committee'
      when 'Thesis'
        'Undergraduate Honors Thesis'
      when 'Final Paper'
        "Master's Paper Committee"

      else
        raise DegreeTypeError, "Unexpected Degree Type: #{degree_type.strip}"
      end
    end

    def extract_year(date_string)
      return nil if date_string.blank?

      Date.parse(date_string).year
    rescue ArgumentError
      nil
    end

    def extract_month(date_string)
      return nil if date_string.blank?

      Date.parse(date_string).month
    rescue ArgumentError
      nil
    end

    def within_last_six_months?(date_string)
      return false if date_string.blank?

      Date.parse(date_string) >= 6.months.ago
    end

    def determine_completion_stage(final_submission_approved_at)
      return 'Completed' if final_submission_approved_at.present?

      'In Process'
    end
  end
end
