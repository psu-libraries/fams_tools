class XLSXOutput < SpreadsheetOutput
  def output(axlsx_workbook)
    axlsx_workbook.add_worksheet(name: 'citations') do |sheet|
      sheet.add_row formatted_headers
      works.each do |item|
        sheet.add_row formatted_row(item)
      end
    end
  end
end
