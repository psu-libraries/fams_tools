require 'spreadsheet'
require 'csv'

class ComData::ComParser
  attr_accessor :csv_hash, :csv_object

  def initialize(filepath)
    @csv_object = CSV.read(filepath, encoding: 'ISO-8859-1:UTF-8', quote_char: '"')
    @csv_hash = convert_csv_to_hash(csv_object)
    @flagged = []
  end

  private

  def convert_csv_to_hash(csv_array)
    keys = csv_array[0]
    keys[0].gsub!('ï»¿'.force_encoding('UTF-8'), '')
    csv_array[1..-1].map { |a| keys.zip(a).to_h }
  end
end
