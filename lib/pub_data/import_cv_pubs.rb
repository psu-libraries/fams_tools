class ImportCVPubs
  attr_accessor :filepath

  def initialize(filepath)
    @filepath = filepath
  end

  def import_cv_pubs_data
    data = CSV.read(filepath, { encoding: "UTF-8" } )
    headers = data.first
    data.map! { |n| Hash[ headers.zip(n) ] }
    puts data
  end
end

