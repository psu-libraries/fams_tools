require 'etda/committee_records_client'

module CommitteeData
  class EtdaImporter
    class DegreeTypeError < RuntimeError; end

    ENDPOINTS = {
      etda: {
        url: ENV.fetch('ETDA_API_URL', 'http://localhost:3000'),
        api_token: ENV.fetch('ETDA_API_TOKEN', 'abc123')
      },
      honors: {
        url: ENV.fetch('HONORS_API_URL', 'http://localhost:3001'),
        api_token: ENV.fetch('HONORS_API_TOKEN', 'honors_token')
      },
      millennium_scholars: {
        url: ENV.fetch('MILLENNIUM_SCHOLARS_API_URL', 'http://localhost:3002'),
        api_token: ENV.fetch('MILLENNIUM_SCHOLARS_API_TOKEN', 'ms_token')
      },
      sset: {
        url: ENV.fetch('SSET_API_URL', 'http://localhost:3003'),
        api_token: ENV.fetch('SSET_API_TOKEN', 'sset_token')
      }
    }.freeze

    def import_all
      Faculty.find_each do |faculty|
        import_for_faculty(faculty)
      rescue StandardError => e
        Rails.logger.error("Failed to import committees for #{faculty.access_id}: #{e.message}")
      end
    end

    private

    def import_for_faculty(faculty)
      ENDPOINTS.each do |endpoint_name, config|
        endpoint_result = fetch_from_endpoint(faculty.access_id, config)
        process_endpoint_result(faculty, endpoint_name, endpoint_result)
      end
    end

    def fetch_from_endpoint(access_id, config)
      client = Etda::CommitteeRecordsClient.new(url: config[:url], api_token: config[:api_token])
      committee_data = client.faculty_committees(access_id)
      { success: true, data: committee_data }
    rescue Etda::CommitteeRecordsClient::CommitteeRecordsClientError => e
      { success: false, error: e.message }
    end

    def process_endpoint_result(faculty, endpoint_name, endpoint_result)
      unless endpoint_result[:success]
        Rails.logger.warn("Failed to fetch from #{endpoint_name} for #{faculty.access_id}: #{endpoint_result[:error]}")
        return
      end

      committees_data = endpoint_result[:data]['committees']

      committees_data.each do |committee|
        next unless within_last_six_months?(committee['approval_started_at'])

        role, role_other = CommitteeRoleNormalizer.normalize(committee['role'])

        faculty.committees.create!(
          student_fname: committee['student_fname'],
          student_lname: committee['student_lname'],
          role: role,
          role_other: role_other,
          thesis_title: committee['title'],
          type_of_work: map_type_of_work(committee['degree_type']),
          degree_name: committee['degree_name'],
          stage_of_completion: determine_completion_stage(
            committee['final_submission_approved_at']
          ),
          start_year: extract_year(committee['approval_started_at']),
          start_month: extract_month(committee['approval_started_at']),
          completion_year: extract_year(committee['final_submission_approved_at']),
          completion_month: extract_month(committee['final_submission_approved_at'])
        )
      end
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
