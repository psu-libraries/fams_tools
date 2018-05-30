class PublicationListingsController < ApplicationController
  def new
  end

  def create
    puts "METHOD"
    puts params[:method]
    if params[:method] == 'post'
      puts "In post"
      t_name = params[:training_file].original_filename
      t_path = File.join('app', 'parsing_files', t_name)
      File.open(t_path, "wb") { |f| f.write(params[:training_file].read) }

      p_name = params[:publication_file].original_filename
      p_path = File.join('app', 'parsing_files', p_name)
      File.open(p_path, "wb") { |f| f.write(params[:publication_file].read) }
    
      Anystyle.parser.train(t_path, false)
      @citations = Anystyle.parse(p_path, :hash)
      pl = PublicationListing.new(:path => p_path)
      pl.save

      @citations.each_with_index do |item, index|
        work = Work.new(
            :author => item[:author], 
            :title => item[:title], 
            :item => item[:journal], 
            :volume => item[:volume], 
            :edition => item[:edition], 
            :pages => item[:pages], 
            :date => item[:date], 
            :booktitle => item[:booktitle], 
            :container => item[:container], 
            :doi => item[:doi],
            :editor => item[:editor], 
            :institution => item[:institution], 
            :isbn => item[:isbn], 
            :location => item[:location], 
            :note => item[:note], 
            :publisher => item[:publisher], 
            :retrieved => item[:retrieved], 
            :tech => item[:tech], 
            :translator => item[:translator], 
            :unknown => item[:unknown], 
            :url => item[:url],
            :publication_listing => pl
        )
        #work.save
      end
    end
    @publication_listings = PublicationListing.all
    render :index
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
