require 'bibtex'

class Work < ApplicationRecord
  serialize :author
  serialize :editor
  belongs_to :publication_listing

  def self.to_csv
    CSV.generate({encoding: "utf-8"}) do |csv|

      cv_owner = Faculty.find_by(access_id: all.pluck(:username).uniq.first)
      workstype = all.pluck(:contype).uniq.first.downcase

      header_map = [:username, "IGNORE", :title, :journal, :volume, :edition, :pages, :date, :booktitle, :container, :genre, :contype, :doi,
        :editor, :institution, :isbn, :location, :note, :publisher, :retrieved, :tech, :translator, :unknown, :url]

      empty_col_indices = []

      header_map.each_with_index do |header, index|
        unless header == "IGNORE"
          if all.pluck(header).compact.empty?
            empty_col_indices << index
          end
        end
      end

      if workstype == 'presentation'
        headers = ['USERNAME', 'USER_ID', 'TITLE', 'journal', 'volume', 'edition', 'pages', 'DTY_DATE', 'booktitle', 'NAME', 'type', 'TYPE', 'doi', 'editor', 'ORG', 'isbn', 'LOCATION', 'note', 'publisher',
                    'retrieved', 'tech', 'translator', 'unknown', 'url'
                    ]
      else
        headers = ['USERNAME', 'USER_ID', 'TITLE', 'journal', 'VOLUME', 'EDITION', 'PAGENUM', 'DTY_PUB', 'booktitle', 'JOURNAL_NAME', 'type', 'CONTYPE', 'WEB_ADDRESS', 'EDITORS', 'INSTITUTION', 'ISBNISSN', 
                    'PUBCTYST', 'note', 'PUBLISHER', 'retrieved', 'tech', 'translator', 'unknown', 'url'
                    ]
      end

      empty_col_indices.each do |index|
        headers[index] = :delete
      end

      headers -= [:delete]

      header_length = headers.length

      longest = 0
      all.each do |item|
        unless item[:author].nil?
          if longest < item[:author].length + header_length
            longest = item[:author].length + header_length
          end
        end
      end

      if workstype == 'presentation'
        counter = longest - header_length
        while headers.length < longest
          headers.insert(0, ["PRESENT_AUTH_#{counter}_FACULTY_NAME", "PRESENT_AUTH_#{counter}_FNAME", "PRESENT_AUTH_#{counter}_MNAME", "PRESENT_AUTH_#{counter}_LNAME"])
          counter -= 1
        end
      else
        counter = longest - header_length
        while headers.length < longest
          headers.insert(0, ["INTELLCONT_AUTH_#{counter}_FACULTY_NAME", "INTELLCONT_AUTH_#{counter}_FNAME", "INTELLCONT_AUTH_#{counter}_MNAME", "INTELLCONT_AUTH_#{counter}_LNAME"])
          counter -= 1
        end
      end

      csv << headers.flatten

      all.each do |item, index|
        row = [
          item[:username], Faculty.find_by(access_id: item[:username])&.user_id, item[:title], item[:journal], item[:volume], item[:edition], item[:pages], item[:date], item[:booktitle], item[:container], item[:genre], item[:contype], item[:doi],
          item[:editor]&.join(", "), item[:institution], item[:isbn], item[:location], item[:note], item[:publisher], item[:retrieved], item[:tech], item[:translator],
          item[:unknown], item[:url]
        ]

        empty_col_indices.each do |index|
          row[index] = :delete
        end

        row -= [:delete]

        unless item[:author].nil?
          item[:author]&.reverse&.each do |author|
            if cv_owner.present? && author[2]&.upcase == cv_owner&.l_name&.upcase && author[0][0]&.upcase == cv_owner&.f_name[0]&.upcase
              row.insert(0, [cv_owner&.user_id, author[0], author[1], author[2]])
            else
              row.insert(0, ["", author[0], author[1], author[2]])
            end
          end 

          while row.length < longest
            row.insert(item[:author].length, ["", "", "", ""])
          end
        else
          while row.length < longest
            row.insert(0, ["", "", "", ""])
          end
        end

        csv << row.flatten
      end
    end
  end

  def self.to_bibtex
    bib = BibTeX::Bibliography.new

    all.each do |work|

      authors = []

      if work[:author]
        work[:author].each do |author|
          authors << author.reject(&:blank?).join(' ')
        end
      end

      bibtex_type = :article if ['journal article', 'journal article, in-house'].include? work[:contype].downcase
      bibtex_type = :conference if ['conference proceeding'].include? work[:contype].downcase
      bibtex_type = :book if ['book', 'book, chapter'].include? work[:contype].downcase

      entry = BibTeX::Entry.new

      entry.type = bibtex_type || :article
      entry.author = authors.join(', ') if authors
      entry.title = work[:title] if work[:title]
      entry.journal = work[:container] if work[:container]
      entry.year = work[:date] if work[:date]
      entry.number = work[:edition] if work[:edition]
      entry.pages = work[:pages] if work[:pages]
      entry.note = work[:note] if work[:note]
      entry.volume = work[:volume] if work[:volume]

      bib << entry
    end

    bib
  end
end
