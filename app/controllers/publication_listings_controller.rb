class PublicationListingsController < ApplicationController
  def create
    pl = PublicationListing.new(name: params[:citations_title])
    pl.save
    citations.zip(parsed_citations) do |citation, item|
      work = Work.new(
        work_attrs(citation, item, pl)
      )
      item[:author]&.each do |a|
        formatted_author = [split_name(a[:given]), a[:family]].flatten
        work.authors << Author.create({ f_name: formatted_author[0],
                                        m_name: formatted_author[1],
                                        l_name: formatted_author[2] })
      end
      item[:editor]&.each do |e|
        formatted_editor = [split_name(e[:given]), e[:family]].flatten
        work.editors << Editor.create({ f_name: formatted_editor[0],
                                        m_name: formatted_editor[1],
                                        l_name: formatted_editor[2] })
      end
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

  def update
    @publication_listing = PublicationListing.find_by_id(params[:id])
    @publication_listing.update_attributes(publication_listing_params)
    flash[:notice] = "Update Successful"
    redirect_to(publication_listing_works_path(@publication_listing))
  end

  private

  def parsed_citations
    AnyStyle.parse(params[:citations].to_s)
  end

  def citations
    AnyStyle::Document.parse(params[:citations].to_s)
  end

  def work_attrs(citation, item, publication_listing)
    {
      username: params[:username],
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
      citation: citation.first.to_s,
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

  def publication_listing_params
    params.require(:publication_listing).permit(works_attributes: [:id, :title, :journal, :volume,
                                                                   :edition, :pages, :item, :booktitle,
                                                                   :container, :contype, :genre, :doi,
                                                                   :editor, :institution, :isbn, :location,
                                                                   :note, :publisher, :retrieved, :tech, :translator,
                                                                   :unknown, :url, :username, :date, :_destroy,
                                                                   authors_attributes: [:id, :f_name, :m_name, :l_name, :_destroy],
                                                                   editors_attributes: [:id, :f_name, :m_name, :l_name, :_destroy]])
  end
end
