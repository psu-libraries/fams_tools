require 'pdf-reader'
require 'exiftool_vendored'

class VerifyPostPrint
  def initialize
    @good_pdf = 0
    @good_exif = 0
    @wr_book = Spreadsheet::Workbook.new
    @wr_sheet = wr_book.create_worksheet
  end

  # list of unacceptable file names
  NOT_FILENAMES = ["PROOF", "in+press"]
  # list of acceptable creators
  POST_PRINT_CREATORS = ["Microsoft", "LaTeX", "Preview", "TeX"]
  # list of unacceptable creators
  NOT_POST_PRINT_CREATORS = ["Elsevier", "Arbortext Advanced Print Publisher", "Springer", "Appligent"]
  # list of unacceptable subjects
  NOT_SUBJECTS = ["Journal Pre-proof"]
  # list of unacceptable producers
  NOT_PRODUCERS = ["iText"]

  def verify
    puts "loop over directory"
    Dir.glob("#{directory_to_examine}/*.pdf").each_with_index do |file, file_index|

      if file_index == 0
        headings = ["File", "PDF File Status", "PDF Status Message", "PDF Verbose", "EXIF File Status", "EXIF Status Message", "Journal Article Version", "EXIF Verbose"]
        wr_sheet.insert_row( file_index, headings )
      else

        next if File.directory?(file) # skip the loop if the file is a directory

        base = File.basename(file)
        wr_sheet.row(file_index).insert 0, base

        pdf_validation = {}
        pdf_validation = is_pdf_file_valid(file)
        puts "PDF VALIDATION\n"
        puts pdf_validation
        puts "\n"

        exif_validation = {}
        exif_validation = is_exif_valid(file)
        puts "EXIF VALIDATION\n"
        puts exif_validation
        puts "\n"

        wr_sheet.row(file_index).insert 1, pdf_validation[:status]
        wr_sheet.row(file_index).insert 2, pdf_validation[:message]
        wr_sheet.row(file_index).insert 3, pdf_validation[:verbose].inspect

        wr_sheet.row(file_index).insert 4, exif_validation[:status]
        wr_sheet.row(file_index).insert 5, exif_validation[:message]
        wr_sheet.row(file_index).insert 6, exif_validation[:verbose][:journal_article_version]
        wr_sheet.row(file_index).insert 7, exif_validation[:verbose].inspect

        if pdf_validation[:status].nil? and exif_validation[:status].nil?
          puts "Couldn't determine\n\n"
        elsif pdf_validation[:status]
          puts "Passed Check (pdf)\n\n"
        elsif exif_validation[:status]
          puts "Passed Check (exif)\n\n"
        else
          puts "Failed\n\n"
        end
      end

    end
    wr_book.write save_spreadsheet_name
    puts "Found #{@good_pdf} acceptable PDFs from PDF library"
    puts "Found #{@good_exif} acceptable PDFs from EXIF library"
  end

  private

    def is_pdf_file_valid(file_path)

      validation = {}
      validation[:status] = nil
      validation[:message] = ""
      validation[:verbose] = ""

      if NOT_FILENAMES.any? { |s| file_path.include?(s) }
        validation[:status] = false
        validation[:message] = "Bad file name"
        return validation
      end

      PDF::Reader.open(file_path) do |reader|
        validation[:verbose] = reader.info
        puts reader.info
        if reader.info.key? (:Subject)
          begin
            if NOT_SUBJECTS.any? { |s| reader.info[:Subject].include?(s) }
              validation[:status] = false #good = false
              validation[:message] = "Bad Subject"
              return validation
            end
          rescue NoMethodError => e
            validation[:status] = false
            validation[:message] = "Couldn't read subject"
            return validation
          rescue => e
            validation[:status] = false
            validation[:message] = "Couldn't read subject (Error)"
            return validation
          end
        end
        if reader.info.key? (:Creator) and reader.info[:Creator].is_a?(String)
          if POST_PRINT_CREATORS.any? { |s| reader.info[:Creator].include?(s) }
            @good_pdf += 1
            validation[:status] = true #good = true
            validation[:message] = "Found a good creator"
            return validation
          elsif NOT_POST_PRINT_CREATORS.any? { |s| reader.info[:Creator].include?(s) }
            validation[:status] = false #good = false
            validation[:message] = "Found a bad creator"
            return validation
          end
        end
      end
      return validation
    end

    def is_exif_valid(file_path)
      validation = {}
      validation[:status] = nil
      validation[:message] = ""
      validation[:verbose] = ""

      e = Exiftool.new(file_path)

      puts "Exif:"
      h = e.to_hash
      validation[:verbose] = h
      puts h[:journal_article_version]
      if !h[:journal_article_version].nil?
        # AM: accepted manuscript - pass
        if h[:journal_article_version].downcase == "am"
          @good_exif += 1
          validation[:status] = true
          validation[:message] = "accepted manuscript"
          return validation
        end
        # P: proof - fail
        if h[:journal_article_version].downcase == "p"
          validation[:status] = false
          validation[:message] = "proof"
          return validation
        end
        # VoR: version of record - fail
        if h[:journal_article_version].downcase == "vor"
          validation[:status] = false
          validation[:message] = "version of record"
          return validation
        end
      end

      if !h[:subject].nil? and h[:subject].is_a?(String) and h[:subject].downcase.include? "downloaded from"
        validation[:status] = false
        validation[:message] = "subject contains downloaded from"
        return validation
      end

      if !h[:creator].nil? and h[:creator].is_a?(String)
        if NOT_POST_PRINT_CREATORS.any? { |s| h[:creator].include?(s) }
          validation[:status] = false
          validation[:message] = "Found a bad creator"
          return validation
        end
      end

      if !h[:creator_tool].nil? and h[:creator_tool].is_a?(String)
        if NOT_POST_PRINT_CREATORS.any? { |s| h[:creator_tool].include?(s) }
          validation[:status] = false
          validation[:message] = "Found a bad creator"
          return validation
        end
      end

      if !h[:producer].nil? and h[:producer].is_a?(String)
        if NOT_PRODUCERS.any? { |s| h[:producer].include?(s) }
          validation[:status] = false
          validation[:message] = "Found a bad producer"
          return validation
        end
      end

      return validation
    end

    def directory_to_examine
      "#{Rails.root}/app/post_prints"
    end

    def save_spreadsheet_name
      "#{directory_to_examine}/exif-results-#{Time.now.strftime("%Y-%m-%d %H-%M")}.xls"
    end

    attr_accessor :wr_book, :wr_sheet
end
