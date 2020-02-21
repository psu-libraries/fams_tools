class ImportCVPubs
  attr_accessor :data

  def initialize(filepath)
    @data = CSV.read(filepath, encoding: "utf-8")
  end

  def import_cv_pubs_data
    rows = arrays_to_hashes(data)
    rows.each do |row|
      faculty = Faculty.find_by(access_id: row["USERNAME"].downcase)

      publication = Publication.create!(publication_attributes(row))
      
      PublicationFacultyLink.create!(faculty: faculty,
                                     publication: publication,
                                     category: row["CONTYPE"])

      external_author = ExternalAuthor.new()
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
            external_author.f_name = row[key]
            counter += 1
          when 3
            external_author.m_name = row[key]
            counter += 1
          when 4
            external_author.l_name = row[key]
            external_author.publication = publication
            external_author.save! unless(external_author.f_name.blank? && external_author.m_name.blank? && external_author.l_name.blank?)
            external_author = ExternalAuthor.new
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

  def publication_attributes(row)
    {
      title: row["TITLE"],
      volume: row["VOLUME"],
      edition: row["EDITION"],
      page_range: row["PAGENUM"],
      dty: row["DTY_PUB"],
      journal_title: row["JOURNAL_NAME"],
      web_address: row["WEB_ADDRESS"],
      editors: row["EDITORS"],
      institution: row["INSTITUTION"],
      isbnissn: row["ISBNISSN"],
      pubctyst: row["PUBCTYST"]
    }
  end
end

