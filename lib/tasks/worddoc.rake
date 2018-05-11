require 'pp'
require 'yaml'

namespace :convert do
  desc "Parsing a CV"

  task :publications, [:publication_file] => [:environment] do |task, args|
    training_file = "training.txt"
    #publication_file = args[:publication_file] #"abrams.txt"
    publication_file = "abrams.txt"
    puts training_file
    puts publication_file 
    Anystyle.parser.train(training_file, false)
    b = Anystyle.parse(publication_file, :hash)
    File.write('publications.yml', b.to_yaml)
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
