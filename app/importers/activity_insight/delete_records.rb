class ActivityInsight::DeleteRecords
  class InvalidResource < StandardError; end

  RESOURCES = %w[CONGRANT SCHTEACH INTELLCONT ADMIN EDUCATION PASTHIST ADMIN_ASSIGNMENTS AWARDHONOR
                 FACDEV INSTRUCT_TAUGHT OCTEACH NCTEACH COURSE_EVAL ACADVISE COURSES CRIA DSL SPONSOR_REPORT
                 PERFORM_EXHIBIT PRESENT INTELLPROP MEMBER SERVICE_INTERNAL SERVICE_EXTERNAL NIH_BIOSKETCH
                 BIOSKETCH NSF_SUPPORT STUDENT_RATING].freeze

  def initialize(resource, target)
    raise InvalidResource, 'Invalid Resource' unless RESOURCES.include? resource.to_s

    @resource = resource
    @target = target
  end

  def delete
    xmls_array = []
    CSV.foreach(csv_path, headers: true).to_a.in_groups_of(1000) do |batch|
      builder = Nokogiri::XML::Builder.new do |xml|
        xml.Data do
          xml.send(resource.to_s) do
            batch.each do |row|
              next if row.blank?

              xml.item('id' => row['ID'])
            end
          end
        end
      end
      xmls_array << builder.to_xml
    end
    request(xmls_array)
  end

  private

  def csv_path
    "#{Rails.root.join('app/parsing_files/delete.csv')}"
  end

  def request(xmls_array)
    integrator = ActivityInsight::IntegrateData.new(xmls_array, target, :delete)
    integrator.integrate
  end

  attr_reader :target, :resource
end
