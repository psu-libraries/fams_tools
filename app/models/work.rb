require 'bibtex'

class Work < ApplicationRecord
  serialize :author
  serialize :editor
  belongs_to :publication_listing

  def self.cv_owner
    Faculty.find_by(access_id: all.pluck(:username).uniq.first)
  end

  def self.workstype
    all.pluck(:contype).uniq.first.downcase
  end

  def self.header_map
    %i[username ignore title journal volume edition pages
       year month day booktitle container contype doi
       editor institution isbn location note publisher retrieved
       tech translator unknown url]
  end

  def self.empty_col_indices
    indices = []
    header_map.each_with_index do |header, index|
      unless header == :ignore
        indices << index if all.pluck(header).compact.empty?
      end
    end
    indices
  end

  def self.pres_headers
    %w[USERNAME USER_ID TITLE journal VOLUME EDITION PAGENUM DTY_END DTM_END DTD_END
       booktitle NAME TYPE doi editor ORG isbn LOCATION COMMENT publisher
       retrieved tech translator unknown url]
  end

  def self.pub_headers
    %w[USERNAME USER_ID TITLE journal VOLUME EDITION PAGENUM DTY_END DTM_END DTD_END
       booktitle JOURNAL_NAME CONTYPE WEB_ADDRESS EDITORS INSTITUTION ISBNISSN
       PUBCTYST COMMENT PUBLISHER retrieved tech translator unknown url]
  end

  def self.headers
    return pres_headers if workstype == 'presentations'

    pub_headers
  end

  def self.mark_empty_headers
    empty_col_indices.each do |index|
      headers[index] = :delete
    end
  end

  def self.remove_empty_headers
    headers.delete(:delete)
  end

  def self.header_length
    headers.length
  end

  def self.longest
    num = 0
    all.each do |item|
      unless item[:author].nil?
        if num < item[:author].length + header_length
          num = item[:author].length + header_length
        end
      end
    end
    num
  end

  def self.formatted_pres_headers(header_item)
    counter = longest - header_length
    while header_item.length < longest
      header_item.insert(header_length, ["PRESENT_AUTH_#{counter}_FACULTY_NAME", "PRESENT_AUTH_#{counter}_FNAME", "PRESENT_AUTH_#{counter}_MNAME", "PRESENT_AUTH_#{counter}_LNAME"])
      counter -= 1
    end
    header_item
  end

  def self.formatted_pub_headers(header_item)
    counter = longest - header_length
    while header_item.length < longest
      header_item.insert(header_length, ["INTELLCONT_AUTH_#{counter}_FACULTY_NAME", "INTELLCONT_AUTH_#{counter}_FNAME", "INTELLCONT_AUTH_#{counter}_MNAME", "INTELLCONT_AUTH_#{counter}_LNAME"])
      counter -= 1
    end
    header_item
  end

  def self.formatted_headers
    mark_empty_headers
    remove_empty_headers
    return formatted_pres_headers(headers) if workstype == 'presentations'

    formatted_pub_headers(headers)
  end

  def self.row(item)
    [
        item[:username], Faculty.find_by(access_id: item[:username])&.user_id,
        item[:title], item[:journal], item[:volume], item[:edition],
        item[:pages], item[:year], item[:month], item[:day], item[:booktitle],
        item[:container], item[:contype], item[:doi], item[:editor]&.join(", "),
        item[:institution], item[:isbn], item[:location], item[:note],
        item[:publisher], item[:retrieved], item[:tech], item[:translator],
        item[:unknown], item[:url]
    ]
  end

  def self.mark_empty_row(row_item)
    empty_col_indices.each do |index|
      row_item[index] = :delete
    end
  end

  def self.remove_empty_row(row_item)
    row_item.delete(:delete)
  end

  def self.formatted_row(item)
    row_item = row(item)
    mark_empty_row(row_item)
    remove_empty_row(row_item)
    unless item[:author].nil?
      item[:author]&.reverse&.each do |author|
        if cv_owner.present? && author[2]&.upcase == cv_owner&.l_name&.upcase && author[0][0]&.upcase == cv_owner&.f_name[0]&.upcase
          row_item.insert(header_length, [cv_owner&.user_id, author[0], author[1], author[2]])
        else
          row_item.insert(header_length, ["", author[0], author[1], author[2]])
        end
      end

      while row_item.length < longest
        row_item.insert(header_length + item[:author].length, ["", "", "", ""])
      end
    else
      while row_item.length < longest
        row_item.insert(header_length, ["", "", "", ""])
      end
    end
    row_item.flatten
  end

  def self.to_csv
    CSV.generate({encoding: "utf-8"}) do |csv|
      csv << formatted_headers
      all.each do |item|
        csv << formatted_row(item)
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
      entry.year = work[:year] if work[:year]
      entry.number = work[:edition] if work[:edition]
      entry.pages = work[:pages] if work[:pages]
      entry.note = work[:note] if work[:note]
      entry.volume = work[:volume] if work[:volume]

      bib << entry
    end

    bib
  end
end
