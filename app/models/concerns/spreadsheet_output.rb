class SpreadsheetOutput < WorkOutputs
  include OutputDates

  def output(*_args)
    csv = CSV.generate(encoding: 'utf-8') do |csv|
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
    if workstype == 'presentations'
      header_array << PRES_HEADERS
      @header_map = PRES_MAP
    else
      header_array << PUB_HEADERS
      @header_map = PUB_MAP
    end
    header_array.flatten
  end

  def header_length
    headers.length
  end

  def longest
    num = 0
    works.each do |item|
      next if item.authors.blank?

      next unless num < item.authors.length + header_length

      num = item.authors.length + header_length
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
    return formatted_pres_headers(headers_obj) if workstype == 'presentations'

    formatted_pub_headers(headers_obj)
  end

  def row(item)
    row_arr = @header_map.map do |key|
      row_assign(item, key)
    end
    row_arr.flatten
  end

  def row_assign(item, key)
    if key == :ignore
      return cv_owner.user_id if cv_owner
    elsif key == :date
      return formatted_date(split_date(item[key]))
    elsif key == :editors
      return item.editors.collect { |e| "#{e.f_name} #{e.m_name} #{e.l_name}" }.join(', ')
    end

    return item[key]&.join(', ') if key == :editor

    item[key]
  end

  def formatted_date(date)
    if workstype == 'presentations' && date.nil?
      return ['', '', '', '', '', '']
    elsif workstype == 'presentations' && date.instance_of?(Array)
      return [year(date[0]), month(date[0]), day(date[0]),
              year(date[1]), month(date[1]), day(date[1])]
    elsif workstype == 'presentations' && date.instance_of?(Date)
      return [year(date), month(date), day(date), '', '', '']
    elsif workstype == 'presentations'
      return [date.to_s, '', '', '', '', '']
    end

    return [year(date), month(date), day(date)] if date.instance_of?(Date)

    [date, '', '']
  end

  def split_date(date)
    return nil if date.nil?

    if date.match(/[0-9]-[0-9]?[0-9],/)
      first_date = date.gsub(/-[0-9]?[0-9]/, '')
      second_date = date.gsub(/[0-9]?[0-9]-/, '')
      return [first_date, second_date]
    end

    begin
      Date.parse(date.to_s)
    rescue ArgumentError
      date.to_s
    end
  end

  def formatted_row(item)
    row_item = row(item)
    format_row(row_item, item)
    row_item.flatten
  end

  def format_row(row_item, item)
    if item.authors.present?
      format_author_data(row_item, item)
    else
      match_length(row_item)
    end
  end

  def format_author_data(row_item, item)
    item.authors&.reverse&.each do |author|
      insert_authors(row_item, author)
    end
    match_length_author(row_item, item)
  end

  def insert_authors(row_item, author)
    row_item.insert(header_length, [author.f_name, author.m_name, author.l_name])
  end

  def match_length_author(row_item, item)
    row_item.insert(header_length + item.authors.length, ['', '', '', '']) while row_item.length < longest
  end

  def match_length(row_item)
    row_item.insert(header_length, ['', '', '', '']) while row_item.length < longest
  end

  def remove_empty_cols(csv)
    csv = CSV.parse(csv, headers: true)
    headers.each do |header|
      csv.delete(header) if csv[header].reject { |s| s.nil? || s.strip.empty? }.blank?
    end
    csv
  end
end
