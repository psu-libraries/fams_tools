class ConverterController < ApplicationController

  def index 
    respond_to do |format|
      format.html
      format.xlsx {}
    end
  end

  def show

  end

  def citation_parse
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
      work.save
    end 

  end

  def citation_parse_x
    #if params[:training_file] and not params[:training_file].path.blank?
    #  puts params[:training_file].path
    #  puts "training"
    #end
    puts "training"
    puts params[:training_file].path
    t_name = params[:training_file].original_filename
    t_path = File.join('app', 'parsing_files', t_name)
    File.open(t_path, "wb") { |f| f.write(params[:training_file].read) }
    puts t_path
    puts "--------"

    puts "parsing"
    puts params[:publication_file].path
    p_name = params[:publication_file].original_filename
    p_path = File.join('app', 'parsing_files', p_name)
    File.open(p_path, "wb") { |f| f.write(params[:publication_file].read) }
    puts p_path 
   
  
    Anystyle.parser.train(t_path, false)
    @citations = Anystyle.parse(p_path, :hash)
    respond_to do |format|
      format.html 
      #{ render xlsx: 'citation_parse', filename: 'citation_parse.xlsx',  xlsx: 'citation_parse'}
      #headers['Content-Disposition'] ||= 'attachment; filename="citation_parse.xlsx"'
      #headers['Content-Type'] ||= 'text/xlsx'
    end 
    
#    ss = Axlsx::Package.new
#    wb = ss.workbook.add_worksheet(:name => "citations")
#    wb.add_row ['author', 'title', 'journal', 'volume', 'edition', 'pages', 'date', 'booktitle', 'container', 'doi', 'editor', 'institution', 'isbn', 
#      'location', 'note', 'publisher', 'retrieved', 'tech', 'translator', 'unknown', 'url'
#     ]
#    citations.each_with_index do |item, index|
#      wb.add_row [ 
#          item[:author], item[:title], item[:journal], item[:volume], item[:edition], item[:pages], item[:date], item[:booktitle], item[:container], item[:doi],
#          item[:editor], item[:institution], item[:isbn], item[:location], item[:note], item[:publisher], item[:retrieved], item[:tech], item[:translator], 
#          item[:unknown], item[:url]
#        ]
#    end 
#    
#    ss.serialize('app/parsing_files/test.xlsx')
    #render :index
  end

  def converter_params
    params.require(:converter).permit(:publication_file, :training_file)
  end

  protected

end
