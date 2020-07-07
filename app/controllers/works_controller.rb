class WorksController < ApplicationController
  def index
    @works = Work.where(publication_listing: params[:publication_listing_id])
    @publication_listing = publication_listing
    f = @publication_listing.name
    @xlsx_name = File.basename(f, File.extname(f)) + '.xlsx'
    @csv_name = File.basename(f, File.extname(f)) + '.csv'
    respond_to_formats
  end

  private

  def publication_listing
    PublicationListing.find_by_id(params[:publication_listing_id])
  end

  def respond_to_formats
    respond_to do |format|
      format.html
      format.xlsx { render xlsx: 'index', filename: @xlsx_name }
      format.csv { send_data @works.to_csv, filename: @csv_name }
    end
  end
end
