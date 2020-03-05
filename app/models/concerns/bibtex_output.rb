class BibtexOutput < WorkOutputs
  def output
    bib = BibTeX::Bibliography.new
    works.each do |work|
      this_authors = authors(work)
      bib << entry(work, this_authors)
    end
    bib
  end

  private

  def authors(work)
    authors_arr = []
    if work[:author]
      work[:author].each do |author|
        authors_arr << author.reject(&:blank?).join(' ')
      end
    end
    authors_arr
  end

  def bibtex_type(contype)
    contype_downcase = contype.downcase
    if ['journal article', 'journal article, in-house'].include? contype_downcase
      :article
    elsif ['conference proceeding'].include? contype_downcase
      :conference
    elsif ['book', 'book, chapter'].include? contype_downcase
      :book
    end
  end

  def entry(work, authors)
    entry_obj = BibTeX::Entry.new
    entry_obj.type = bibtex_type(work[:contype]) || :article
    entry_obj.author = authors.join(', ') if authors
    entry_obj.title = work[:title] if work[:title]
    entry_obj.journal = work[:container] if work[:container]
    entry_obj.year = work[:year] if work[:year]
    entry_obj.number = work[:edition] if work[:edition]
    entry_obj.pages = work[:pages] if work[:pages]
    entry_obj.note = work[:note] if work[:note]
    entry_obj.volume = work[:volume] if work[:volume]
    entry_obj
  end
end