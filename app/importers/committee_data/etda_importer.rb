require 'etda/committee_records_client'

module CommitteeData
  class EtdaImporter
    class DegreeTypeError < RuntimeError; end

    def import_all(since: Date.current.prev_month.change(day: 10),
                   until_date: Date.current.change(day: 10))
      Faculty.find_each do |faculty|
        import_for_faculty(faculty, since:, until_date:)
      rescue StandardError => e
        Rails.logger.error("Failed to import committees for #{faculty.access_id}: #{e.message}")
      end
    end

    private

    def import_for_faculty(faculty, since:, until_date:)
      total = 0
      Endpoint.each do |endpoint|
        endpoint_result = fetch_from_endpoint(faculty.access_id, endpoint)
        total += process_endpoint_result(faculty, endpoint.partner, endpoint_result, since:, until_date:)
      end
      Rails.logger.info("Saved #{total} committees for #{faculty.access_id}")
    end

    # Rescues per-endpoint so a single failing system doesn't abort the others.
    def fetch_from_endpoint(access_id, endpoint)
      client = Etda::CommitteeRecordsClient.new(url: endpoint.url, api_token: endpoint.api_token)
      client.faculty_committees(access_id)
    rescue Etda::CommitteeRecordsClient::CommitteeRecordsClientError => e
      { success: false, error: e.message }
    end

    def process_endpoint_result(faculty, endpoint_name, endpoint_result, since:, until_date:)
      unless endpoint_result[:success]
        Rails.logger.error("Failed to fetch from #{endpoint_name} for #{faculty.access_id}: #{endpoint_result[:error]}")
        return 0
      end

      committees_data = endpoint_result[:data]['committees'] || []
      saved = 0

      committees_data.each do |committee_data|
        next unless within_import_window?(committee_data['approval_started_at'], since:, until_date:)

        role, role_other = CommitteeRoleNormalizer.normalize(committee_data['role'])
        type_of_work = map_type_of_work(committee_data['degree_type'])
        start_year = extract_year(committee_data['approval_started_at'])
        start_month = extract_month(committee_data['approval_started_at'])

        committee = faculty.committees.find_or_initialize_by(
          student_fname: committee_data['student_fname'],
          student_lname: committee_data['student_lname'],
          role: role,
          type_of_work: type_of_work,
          start_year: start_year,
          start_month: start_month
        )

        committee.assign_attributes(
          role_other: role_other,
          thesis_title: sanitize(committee_data['title']),
          degree_name: committee_data['degree_name'],
          stage_of_completion: determine_completion_stage(committee_data['final_submission_approved_at']),
          completion_year: extract_year(committee_data['final_submission_approved_at']),
          completion_month: extract_month(committee_data['final_submission_approved_at'])
        )

        committee.save!
        saved += 1
      end

      saved
    end

    def sanitize(value)
      value.to_s.gsub(/[\x00-\x08\x0B\x0C\x0E-\x1F]/, '')
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

    def within_import_window?(date_string, since:, until_date:)
      return false if date_string.blank?

      Date.parse(date_string).between?(since.to_date, until_date.to_date)
    rescue ArgumentError
      false
    end

    def determine_completion_stage(final_submission_approved_at)
      return 'Completed' if final_submission_approved_at.present?

      'In Process'
    end
  end
end
