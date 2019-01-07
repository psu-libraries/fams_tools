class ImportCVPubs
  attr_accessor :data

  def initialize(filepath)
    @data = CSV.read(filepath, { encoding: "UTF-8" } )
  end

  def import_cv_pubs_data
    rows = arrays_to_hashes(data)
    rows.each do |row|

    end
  end

  private

  def arrays_to_hashes(data)
    headers = data.first
    data.map! { |n| Hash[ headers.zip(n) ] }
  end

  def publication_attributes(row)
  end
end

