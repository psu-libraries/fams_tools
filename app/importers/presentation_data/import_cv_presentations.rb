class ImportCVPresentations
  attr_accessor :data

  def initialize(filepath)
    @data = CSV.read(filepath, { encoding: "UTF-8" } )
  end

  def import_cv_presentations_data
    rows = arrays_to_hashes(data)
    rows.each do |row|
      faculty = Faculty.find_by(user_id: row["USER_ID"])

      presentation = Presentation.create!(presentation_attributes(row).merge!({ faculty: faculty }))

      presentation_contributor = PresentationContributor.new()
      counter = 1 
      row.each_key do |key|
        if key.include? "AUTH"
          case counter
          when 1
            unless row[key].nil?
              next
            end 
            counter += 1
          when 2
            presentation_contributor.f_name = row[key]
            counter += 1
          when 3
            presentation_contributor.m_name = row[key]
            counter += 1
          when 4
            presentation_contributor.l_name = row[key]
            presentation_contributor.presentation = presentation
            presentation_contributor.save! unless(presentation_contributor.f_name.blank? && presentation_contributor.m_name.blank? && presentation_contributor.l_name.blank?)
            presentation_contributor = PresentationContributor.new
            counter = 1 
          end 
        end 
      end 
    end 
  end 

  private

  def arrays_to_hashes(data)
    headers = data.first
    headers.first.gsub!("\xEF\xBB\xBF".force_encoding("UTF-8"), '')
    data[1..-1].map! { |n| Hash[ headers.zip(n) ] }
  end

  def presentation_attributes(row)
    {
      title: row["TITLE"],
      dty_date: row["DTY_DATE"],
      name: row["NAME"],
      org: row["ORG"],
      location: row["LOCATION"]
    }
  end
end
