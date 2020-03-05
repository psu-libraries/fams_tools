class SpreadsheetOutput < WorkOutputs
  def output
    # Defined in subclass
  end

  private

  def empty_col_indices
    indices = []
    HEADER_MAP.each_with_index do |header, index|
      unless header == :ignore
        indices << index if works.pluck(header).compact.empty?
      end
    end
    indices
  end

  def headers
    header_array = []
    header_array << PRES_HEADERS if workstype == 'presentations'
    header_array << PUB_HEADERS if workstype != 'presentations'
    header_array.flatten
  end

  def marked_empty_headers
    headers_item = headers
    empty_col_indices.each do |index|
      headers_item[index] = :delete
    end
    headers_item
  end

  def stripped_headers(marked_headers)
    marked_headers.delete(:delete)
    marked_headers
  end

  def header_length
    stripped_headers(marked_empty_headers).length
  end

  def longest
    num = 0
    works.each do |item|
      next if item[:author].nil?

      next unless num < item[:author].length + header_length

      num = item[:author].length + header_length
    end
    num
  end

  def formatted_pres_headers(header_item)
    counter = longest - header_length
    while header_item.length < longest
      header_item.insert(header_length, present_auth_headers(counter))
      counter -= 1
    end
    header_item.flatten
  end

  def present_auth_headers(counter)
    %W[PRESENT_AUTH_#{counter}_FACULTY_NAME PRESENT_AUTH_#{counter}_FNAME
       PRESENT_AUTH_#{counter}_MNAME PRESENT_AUTH_#{counter}_LNAME]
  end

  def formatted_pub_headers(header_item)
    counter = longest - header_length
    while header_item.length < longest
      header_item.insert(header_length, intellcont_auth_headers(counter))
      counter -= 1
    end
    header_item.flatten
  end

  def intellcont_auth_headers(counter)
    %W[INTELLCONT_AUTH_#{counter}_FACULTY_NAME INTELLCONT_AUTH_#{counter}_FNAME
       INTELLCONT_AUTH_#{counter}_MNAME INTELLCONT_AUTH_#{counter}_LNAME]
  end

  def formatted_headers
    headers_cleaned = stripped_headers(marked_empty_headers)
    if workstype == 'presentations'
      return formatted_pres_headers(headers_cleaned)
    end

    formatted_pub_headers(headers_cleaned)
  end

  def row(item)
    row_arr = []
    HEADER_MAP.each do |key|
      row_arr << row_assign(item, key)
    end
    row_arr
  end

  def row_assign(item, key)
    if key == :ignore
      return Faculty.find_by(access_id: item[:username])&.user_id
    end

    return item[key]&.join(', ') if key == :editor

    item[key]
  end

  def formatted_row(item)
    row_item = row(item)
    mark_empty_row(row_item)
    remove_empty_row(row_item)
    format_row(row_item, item)
    row_item.flatten
  end

  def mark_empty_row(row_item)
    empty_col_indices.each do |index|
      row_item[index] = :delete
    end
  end

  def remove_empty_row(row_item)
    row_item.delete(:delete)
  end

  def format_row(row_item, item)
    if item[:author].present?
      format_author_data(row_item, item)
    else
      match_length(row_item)
    end
  end

  def format_author_data(row_item, item)
    item[:author]&.reverse&.each do |author|
      insert_authors(row_item, author)
    end
    match_length_author(row_item, item)
  end

  def insert_authors(row_item, author)
    if can_insert_owner(author)
      row_item.insert(header_length, [cv_owner&.user_id, author[0],
                                      author[1], author[2]])
    else
      row_item.insert(header_length, ['', author[0], author[1], author[2]])
    end
  end

  def can_insert_owner(author)
    cv_owner.present? && author_is_owner(author)
  end

  def author_is_owner(author)
    owner_f_name = cv_owner&.f_name
    cond1 = author[2]&.upcase == cv_owner&.l_name&.upcase
    cond2 = author[0][0]&.upcase == owner_f_name[0]&.upcase
    cond1 && cond2
  end

  def match_length_author(row_item, item)
    while row_item.length < longest
      row_item.insert(header_length + item[:author].length, ['', '', '', ''])
    end
  end

  def match_length(row_item)
    while row_item.length < longest
      row_item.insert(header_length, ['', '', '', ''])
    end
  end
end
