class AiBackupsListingController < ApplicationController
  def index
    @filenames = collect_file_names
  end

  private

  def collect_file_names
    filenames = []
    Dir.foreach("#{Rails.root}/public/psu") do |item|
      next if ['.', '..'].include? item

      filenames << item
    end
    filenames
  end
end
