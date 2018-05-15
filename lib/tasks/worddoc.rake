require 'pp'
require 'yaml'
require 'spreadsheet'

namespace :convert do
  desc "Parsing a CV"

  task :publications, [:publication_file] => [:environment] do |task, args|
    labels = ['author', 'title', 'journal', 'volume', 'edition', 'pages', 'date', 'booktitle', 'container', 'doi', 'editor', 'institution', 'isbn', 'location', 'note', 'publisher', 'retrieved', 'tech', 'translator', 'unknown', 'url']
    training_file = "training.txt"
    publication_file = args[:publication_file] #"abrams.txt"
    publication_file = "abrams.txt"
    puts training_file
    puts publication_file 
    Anystyle.parser.train(training_file, false)
    b = Anystyle.parse(publication_file, :hash)
    author = 0
    title = 1
    journal = 2 
    volume = 3 
    edition = 4
    pages = 5
    date = 6
    booktitle = 7
    container = 8
    doi = 9
    editor = 10 
    institution = 11
    isbn = 12 
    location = 13
    note = 14
    publisher = 15
    retrieved = 16
    tech = 17
    translator = 18
    unknown = 19
    url = 20 
    wb = Spreadsheet::Workbook.new 'abrams.xls'
    wb_sheet = wb.create_worksheet
    counter = 0 
    wb_sheet.row(0).concat labels
    b.each_with_index do |item, index|
      wb_sheet.row(index+1)[author] = item[:author]
      wb_sheet.row(index+1)[booktitle] = item[:booktitle]
      wb_sheet.row(index+1)[container] = item[:container]
      wb_sheet.row(index+1)[date] = item[:date]
      wb_sheet.row(index+1)[doi] = item[:doi]
      wb_sheet.row(index+1)[edition] = item[:edition]
      wb_sheet.row(index+1)[editor] = item[:editor]
      wb_sheet.row(index+1)[institution] = item[:institution]
      wb_sheet.row(index+1)[isbn] = item[:isbn]
      wb_sheet.row(index+1)[journal] = item[:journal]
      wb_sheet.row(index+1)[location] = item[:location]
      wb_sheet.row(index+1)[note] = item[:note]
      wb_sheet.row(index+1)[pages] = item[:pages]
      wb_sheet.row(index+1)[publisher] = item[:publisher]
      wb_sheet.row(index+1)[retrieved] = item[:retrieved]
      wb_sheet.row(index+1)[tech] = item[:tech]
      wb_sheet.row(index+1)[title] = item[:title]
      wb_sheet.row(index+1)[translator] = item[:translator]
      wb_sheet.row(index+1)[unknown] = item[:unknown]
      wb_sheet.row(index+1)[url] = item[:url]
      wb_sheet.row(index+1)[volume] = item[:volume]
    end 
    
    wb.write 'abrams.xls'
    #pp b
  end


  task grants: :environment do
    doc = Docx::Document.open('grants.docx')
    doc.paragraphs.each do |p|
      next if p.to_s.strip.blank?
      puts "------------PARAGRAPH------------"
      puts p
    end
  end

end
