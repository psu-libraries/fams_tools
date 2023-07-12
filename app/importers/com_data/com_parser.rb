require 'spreadsheet'
require 'csv'

class ComData::ComParser

  attr_accessor :csv_hash, :csv_object, :effort

  def initialize(filepath)
    @csv_object = CSV.read(filepath, encoding: 'ISO-8859-1:UTF-8', quote_char: nil, force_quotes: true)
    @csv_hash = convert_csv_to_hash(csv_object)
    @flagged = []
    @effort = (filepath =~ /ume_faculty_effort/)
    rename_csv_header unless @effort
  end

  def rename_csv_header
    @csv_object[0][7] = 'EVENT_TYPE'
  end

  private

  def convert_csv_to_hash(csv_array)
    keys = csv_array[0]
    keys[0].gsub!("ï»¿".force_encoding("UTF-8"), '')
    csv_array[1..-1].map{ |a| Hash[ keys.zip(a) ] }
  end
end
