class CSVOutput < SpreadsheetOutput
  def output
    CSV.generate({encoding: "utf-8"}) do |csv|
      csv << formatted_headers
      works.each do |item|
        csv << formatted_row(item)
      end
    end
  end
end
