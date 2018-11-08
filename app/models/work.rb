class Work < ApplicationRecord
  serialize :author
  serialize :editor
  belongs_to :publication_listing

  def self.to_csv
    CSV.generate({encoding: "utf-8"}) do |csv|

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

      headers = ['USERNAME', 'USER_ID', 'TITLE', 'journal', 'VOLUME', 'EDITION', 'PAGENUM', 'DTY_PUB', 'booktitle', 'JOURNAL_NAME', 'type', 'CONTYPE', 'WEB_ADDRESS', 'EDITORS', 'INSTITUTION', 'ISBNISSN', 
      'PUBCTYST', 'note', 'PUBLISHER', 'retrieved', 'tech', 'translator', 'unknown', 'url'
      ]

      empty_col_indices.each do |index|
        headers[index] = :delete
      end

      headers -= [:delete]

      header_length = headers.length

      longest = 0
      all.each do |item|
        unless item[:author] == nil
          if longest < item[:author].length + header_length
            longest = item[:author].length + header_length
          end
        end
      end

      counter = longest - header_length
      while headers.length < longest
        headers.insert(0, ["INTELLCONT_AUTH_#{counter}_FACULTY_NAME", "INTELLCONT_AUTH_#{counter}_FNAME", "INTELLCONT_AUTH_#{counter}_MNAME", "INTELLCONT_AUTH_#{counter}_LNAME"])
        counter -= 1
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

        item[:author]&.reverse&.each {|author| row.insert(0, ["", author[0], author[1], author[2]])}

        while row.length < longest
          row.insert(item[:author].length, ["", "", "", ""])
        end

        csv << row.flatten
      end
    end
  end

end
