class PublicationListingsController < ApplicationController
  def create
    pl = PublicationListing.new(name: params[:citations_title])
    pl.save
    citations.each do |item|
      work = Work.new(
        work_attrs(item, pl)
      )
      work.save
    end
    redirect_to publication_listings_url
  end

  def destroy
    pl = PublicationListing.find(params[:publication_listing_id])
    pl.destroy

    flash[:notice] = 'Publication listing successfully deleted.'
    redirect_to publication_listings_path
  end

  def index
    @publication_listings = PublicationListing.all
  end

  private

  def citations
    AnyStyle.parse(params[:citations].to_s)
  end

  def work_attrs(item, publication_listing)
    {
      username: params[:username],
      author: item[:author]&.collect do |e|
        [split_name(e[:given]), e[:family]].flatten
      end,
      title: item.dig(:title, 0),
      journal: item.dig(:journal, 0),
      volume: item.dig(:volume, 0),
      edition: item.dig(:edition, 0),
      pages: item.dig(:pages, 0),
      date: item.dig(:date, 0),
      booktitle: item.dig(:booktitle, 0),
      container: item.dig(:'container-title', 0),
      contype: params[:contype],
      genre: item[:type],
      doi: item.dig(:doi, 0),
      editor: item[:editor]&.collect { |e| "#{e[:given]} #{e[:family]}" },
      institution: item.dig(:institution, 0),
      isbn: item.dig(:isbn, 0),
      location: item.dig(:location, 0),
      note: item.dig(:note, 0),
      publisher: item.dig(:publisher, 0),
      retrieved: item.dig(:retrieved, 0),
      tech: item.dig(:tech, 0),
      translator: item.dig(:translator, 0),
      unknown: item.dig(:unknown, 0),
      url: item.dig(:url, 0),
      publication_listing: publication_listing
    }
  end

  def split_name(name)
    return name if name.blank?

    if name.split(/(?<=[. ])/).length == 2
      [name.split(/(?<=[. ])/)[0].strip, name.split(/(?<=[. ])/)[1].strip]
    else
      [name, '']
    end
  end
end
