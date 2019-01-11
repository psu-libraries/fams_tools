class ImportCVPresentations
  attr_accessor :data

  def initialize(filepath)
    @data = CSV.read(filepath, { encoding: "UTF-8" } )
  end

  def import_cv_presentations_data
    rows = arrays_to_hashes(data)
    rows.each do |row|
      faculty = Faculty.find_by(user_id: row["USER_ID"])
    end
  end
end
