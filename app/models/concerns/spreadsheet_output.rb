class SpreadsheetOutput < WorkOutputs
  def output(*args)
    csv = CSV.generate({ encoding: 'utf-8' }) do |csv|
      csv << formatted_headers
      works.each do |item|
        csv << formatted_row(item)
      end
    end
    remove_empty_cols(csv)
  end

  private

  def headers
    header_array = []
    header_array << PRES_HEADERS if workstype == 'presentations'
    header_array << PUB_HEADERS if workstype != 'presentations'
    header_array.flatten
  end

  def header_length
    headers.length
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
    %W[PRESENT_AUTH_#{counter}_FNAME PRESENT_AUTH_#{counter}_MNAME PRESENT_AUTH_#{counter}_LNAME]
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
    %W[INTELLCONT_AUTH_#{counter}_FNAME INTELLCONT_AUTH_#{counter}_MNAME INTELLCONT_AUTH_#{counter}_LNAME]
  end

  def formatted_headers
    headers_obj = headers
    if workstype == 'presentations'
      return formatted_pres_headers(headers_obj)
    end

    formatted_pub_headers(headers_obj)
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
      return cv_owner.user_id if cv_owner
    end

    return item[key]&.join(', ') if key == :editor

    item[key]
  end

  def formatted_row(item)
    row_item = row(item)
    format_row(row_item, item)
    row_item.flatten
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
    row_item.insert(header_length, [author[0], author[1], author[2]])
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

  def remove_empty_cols(csv)
    csv = CSV.parse(csv, headers: true)
    headers.each do |header|
      csv.delete(header) if csv[header].compact.empty?
    end
    csv
  end
end