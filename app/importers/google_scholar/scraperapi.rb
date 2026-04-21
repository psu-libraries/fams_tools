FACULTY = [
  "example1 psu.edu",
]

$total_credits_used = 0

def find_scholar_id(faculty_name)
  uri = URI('https://api.scraperapi.com/structured/google/search/v1')
  uri.query = URI.encode_www_form(
    api_key: API_KEY,
    query: "\"#{faculty_name}\" site:scholar.google.com",
    country_code: 'us'
  )

  response = Net::HTTP.get_response(uri)
  $total_credits_used += response['sa-credit-cost'].to_i

  name_parts = faculty_name.split[0..-2] # drop "psu.edu"
  first = name_parts.first.downcase
  last  = name_parts.last.downcase

  begin
    data = JSON.parse(response.body)
    (data['organic_results'] || []).each do |result|
      link = result['link'] || ''
      if link.include?('scholar.google.com/citations') && link.include?('user=')
        title = (result['title'] || '').downcase
        if title.include?(first) && title.include?(last)
          user_id = link.split('user=')[1].split('&')[0]
          return user_id
        else
          puts "  ⚠ Skipping '#{result['title']}' — name mismatch"
        end
      end
    end
  rescue
    # ignore parse errors
  end

  nil
end

def scrape_profile(user_id, faculty_name)
  papers  = []
  cstart  = 0

  loop do
    uri = URI('https://api.scraperapi.com/')
    uri.query = URI.encode_www_form(
      api_key:      API_KEY,
      url:          "https://scholar.google.com/citations?user=#{user_id}&hl=en&sortby=citations&cstart=#{cstart}&pagesize=100",
      country_code: 'us',
      render:       'true',
      premium:      'true',
      max_cost:     '100'
    )

    response = Net::HTTP.get_response(uri)
    $total_credits_used += response['sa-credit-cost'].to_i

    page_papers = parse_papers(response.body, faculty_name)
    papers.concat(page_papers)

    break if page_papers.length < 100

    cstart += 100
    puts "  Fetching page #{cstart / 100 + 1}..."
    sleep 2
  end

  papers
end

def parse_papers(html, faculty_name)
  doc    = Nokogiri::HTML(html)
  papers = []

  doc.css('#gsc_a_b .gsc_a_tr').each do |row|
    title_el = row.at_css('.gsc_a_at')
    cited_el = row.at_css('.gsc_a_ac')
    year_el  = row.at_css('.gsc_a_hc')

    papers << {
      faculty:   faculty_name,
      title:     title_el ? title_el.text : 'N/A',
      citations: cited_el ? cited_el.text : '0',
      year:      year_el  ? year_el.text  : 'N/A'
    }
  end

  papers
end

def main
  all_results = []

  puts "-" * 50

  FACULTY.each do |faculty_name|
    puts "\nSearching for: #{faculty_name}"

    user_id = find_scholar_id(faculty_name)

    unless user_id
      puts "  ✗ No Scholar profile found"
      next
    end

    puts "  ✓ Found Scholar ID: #{user_id}"
    puts "  Scraping papers..."
    papers = scrape_profile(user_id, faculty_name)

    if papers.any?
      puts "  ✓ Found #{papers.length} papers"
      all_results.concat(papers)
    else
      puts "  ✗ No papers found"
    end

    sleep 2
  end

  File.write("faculty_papers.json", JSON.pretty_generate(all_results))

  puts "\n#{'=' * 50}"
  puts "Done! #{all_results.length} papers saved to faculty_papers.json"
  puts "\n--- Credit Summary ---"
  puts "Total credits used: #{$total_credits_used}"
end

main
