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
  end

  def show
  end
end
