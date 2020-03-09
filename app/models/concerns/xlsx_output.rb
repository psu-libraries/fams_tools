class XLSXOutput < SpreadsheetOutput
  def output(axlsx_workbook)
    csv = super
    csv = CSV.parse(csv.to_csv)
    axlsx_workbook.add_worksheet(name: 'citations') do |sheet|
      csv.each do |row|
        sheet.add_row row
      end
    end
  end
end
