class WorksController < ApplicationController
  def new
  end

  def create
  end

  def update
  end

  def edit
  end

  def destroy
  end

  def index
    @works = Work.where(publication_listing: params[:publication_listing_id])
    @publication_listing = PublicationListing.find_by_id(params[:publication_listing_id])
    f = @publication_listing.path
    xlsx_name = File.basename(f, File.extname(f)) + '.xlsx'
    respond_to do |format|
      format.html
      format.xlsx { render xlsx: 'index', filename: xlsx_name}
    end
  end

  def show
  end
end
