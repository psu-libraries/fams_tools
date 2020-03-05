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
    work[:author]&.each do |author|
      authors_arr << author.reject(&:blank?).join(' ')
    end
    authors_arr
  end

  def entry(work, authors)
    entry_obj = BibTeX::Entry.new
    entry_obj.type = bibtex_type(work[:contype]) || :article
    entry_obj.author = authors.join(', ') if authors
    entry_attrs = %i[title journal year number pages note volume]
    work_attrs = %i[title container year edition pages note volume]
    attrs_mapped = Hash[entry_attrs.zip(work_attrs)]
    attrs_mapped.each { |k, v| entry_obj[k] = work[v] if work[v] }
    entry_obj
  end

  def bibtex_type(contype)
    contype_down = contype.downcase
    if ['journal article', 'journal article, in-house'].include? contype_down
      :article
    elsif ['conference proceeding'].include? contype_down
      :conference
    elsif ['book', 'book, chapter'].include? contype_down
      :book
    end
  end
end
