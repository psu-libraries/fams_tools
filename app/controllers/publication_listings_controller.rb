class PublicationListingsController < ApplicationController
  def new
  end

  def create
    t_path = ""
    p_path = ""

    if not params[:training_file].blank?
      puts "train"
      t_name = 'tmp_file.txt'
      t_path = File.join('app', 'parsing_files', t_name)
      File.open(t_path, "wb") { |f| f.write(params[:training_file].read) }
      #AnyStyle.parser.train(t_path)
    end

    p_name = 'tmp_file.txt'
    p_path = File.join('app', 'parsing_files', p_name)
    File.open(p_path, "wb") { |f| f.write(params[:publication_file].read) }

    @citations = AnyStyle.parse(p_path)
    pl = PublicationListing.new(:name => params[:publication_file].original_filename)
    pl.save

    @citations.each_with_index do |item, index|
      work = Work.new(
          :author => item[:author]&.collect {|e| "#{e[:given]} #{e[:family]}"}, 
          :title => item.dig(:title, 0), 
          :journal => item.dig(:journal, 0),
          :volume => item.dig(:volume, 0),
          :edition => item.dig(:edition, 0),
          :pages => item.dig(:pages, 0),
          :date => item.dig(:date, 0),
          :booktitle => item.dig(:booktitle, 0),
          :container => item.dig(:"container-title", 0),
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
    File.delete(p_path) if File.exist?(p_path)
    File.delete(t_path) if File.exist?(t_path)

    @publication_listings = PublicationListing.all
    redirect_to publication_listings_url 
  end

  def update
  end

  def edit
  end

  def destroy
  end

  def index
    @publication_listings = PublicationListing.all
  end

  def show
  end
end
