class PublicationListingsController < ApplicationController
  def new
  end

  def create

    @citations = AnyStyle.parse(params[:citations].to_s)
    pl = PublicationListing.new(:name => params[:citations_title])
    pl.save

    @citations.each_with_index do |item, index|
      work = Work.new(
          :username => params[:username],
          :author => item[:author]&.collect { |e| [split_name(e[:given]), e[:family]].flatten }, 
          :title => item.dig(:title, 0), 
          :journal => item.dig(:journal, 0),
          :volume => item.dig(:volume, 0),
          :edition => item.dig(:edition, 0),
          :pages => item.dig(:pages, 0),
          :year => year(item),
          :month => month(item),
          :day => day(item),
          :booktitle => item.dig(:booktitle, 0),
          :container => item.dig(:"container-title", 0),
          :contype => params[:contype],
          :genre => item[:type],
          :doi => item.dig(:doi, 0),
          :editor => item[:editor]&.collect {|e| "#{e[:given]} #{e[:family]}"},
          :institution => item.dig(:institution, 0),
          :isbn => item.dig(:isbn, 0), 
          :location => item.dig(:location, 0),
          :note => item.dig(:note, 0),
          :publisher => item.dig(:publisher, 0),
          :retrieved => item.dig(:retrieved, 0),
          :tech => item.dig(:tech, 0),
          :translator => item.dig(:translator, 0),
          :unknown => item.dig(:unknown, 0),
          :url => item.dig(:url, 0),
          :publication_listing => pl
      )
      work.save
      #puts work
    end

    @publication_listings = PublicationListing.all
    redirect_to publication_listings_url 
  end

  def update
  end

  def edit
  end

  def destroy
    @publication_listing = PublicationListing.find(params[:publication_listing_id])
    @publication_listing.destroy

    flash[:notice] = 'Publication listing successfully deleted.'
    redirect_to publication_listings_path
  end

  def index
    @publication_listings = PublicationListing.all
  end

  def show
  end

  private

  def year(item)
    date_held = split_date(item)
    date_held.present? ? date_held[0] : nil
  end

  def month(item)
    date_held = split_date(item)
    date_held.present? ? date_held[1] : nil
  end

  def day(item)
    date_held = split_date(item)
    date_held.present? ? date_held[2] : nil
  end

  def split_date(item)
    item.dig(:date, 0).present? ?  item.dig(:date, 0).split('-') : nil
  end

  def split_name(name)
    if name&.split(/(?<=[. ])/)&.length == 2
      [name&.split(/(?<=[. ])/)[0].strip, name&.split(/(?<=[. ])/)[1].strip]
    else
      [name, ""]
    end
  end
end
