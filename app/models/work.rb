class Work < ApplicationRecord
  serialize :author
  serialize :editor
  belongs_to :publication_listing

  def self.to_csv
    CSV.generate({encoding: "utf-8"}) do |csv|

      headers = ['USERNAME', 'TITLE', 'journal', 'VOLUME', 'EDITION', 'PAGENUM', 'DTY_PUB', 'booktitle', 'JOURNAL_NAME', 'type', 'CONTYPE', 'WEB_ADDRESS', 'EDITORS', 'INSTITUTION', 'ISBNISSN',
                 'PUBCTYST', 'note', 'PUBLISHER', 'retrieved', 'tech', 'translator', 'unknown', 'url']

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
        headers.insert(1, ["INTELLCONT_AUTH_#{counter}_FNAME", "INTELLCONT_AUTH_#{counter}_MNAME", "INTELLCONT_AUTH_#{counter}_LNAME"])
        counter -= 1
      end

      csv << headers.flatten

      all.each do |item, index|
        row = [
          item[:username], item[:title], item[:journal], item[:volume], item[:edition], item[:pages], item[:date], item[:booktitle], item[:container], item[:genre], item[:contype], item[:doi],
          item[:editor]&.join(", "), item[:institution], item[:isbn], item[:location], item[:note], item[:publisher], item[:retrieved], item[:tech], item[:translator],
          item[:unknown], item[:url]
        ]

        item[:author]&.reverse&.each {|author| row.insert(1, [author[0], author[1], author[2]])}

        if row.length < longest
          unless item[:author] == nil
            while row.length < longest
              row.insert(item[:author].length + 1, ["", "", ""])
            end
          else
            while row.length < longest
              row.insert(1, ["", "", ""])
            end
          end
        end

        puts row
        csv << row.flatten
      end
    end
  end

end
