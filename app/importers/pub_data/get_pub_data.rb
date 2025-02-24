class PubData::GetPubData
  class MDBError < StandardError; end
  attr_accessor :user_ids, :pub_json, :pub_hash

  def initialize
    @pub_json = []
    @pub_hash = []
  end

  def call(pub_populate_obj)
    user_ids.each do |user|
      headers = { 'Accept' => 'application/json',
                  'X-API-Key' => "#{Rails.application.config_for(:activity_insight)['metadata_db'][:key]}" }
      url = "https://metadata.libraries.psu.edu/v1/users/#{user}/publications"
      response = HTTParty.get(url, headers:, timeout: 200)
      @pub_json = response
      next unless response.code == 200

      json_to_hash(pub_json)
      format(pub_hash, user)
      pub_populate_obj.populate(pub_hash, user)
    end
  end

  private

  def format(pub_hash, user_id)
    college = Faculty.find_by(access_id: user_id).college
    pub_hash['data'].each do |publication|
      format_type(publication)
      format_month(publication, college)
      format_status(publication, college)
      format_year(publication)
      format_day(publication)
    end
  end

  def json_to_hash(pub_json)
    raise MDBError, pub_json['message'] if [401, 400, 403, 404, 500, 501, 502, 503].include? pub_json['code']

    @pub_hash = JSON.parse(pub_json.body)
  end

  def format_type(publication)
    pub_type = publication['attributes']['publication_type']
    if ['Article', 'Review Article', 'Journal Article, Academic Journal',
        'Academic Journal Article', 'Professional Journal Article'].include?(pub_type)
      publication['attributes']['publication_type'] = 'Journal Article'
    elsif pub_type == 'In-house Journal Article'
      publication['attributes']['publication_type'] = 'Journal Article, In House'
    elsif pub_type == 'Conference Article'
      publication['attributes']['publication_type'] = 'Conference Proceeding'
    elsif pub_type == 'Book/Film/Article Review'
      publication['attributes']['publication_type'] = 'Book Review'
    elsif pub_type == 'Chapter'
      publication['attributes']['publication_type'] = 'Book Chapter'
    elsif pub_type == 'Encyclopedia/Dictionary Entry'
      publication['attributes']['publication_type'] = 'Encyclopedia Entry'
    elsif ['Comment/Debate', 'Editorial', 'Foreword/Postscript', 'Letter', 'Paper', 'Short Survey'].include?(pub_type)
      publication['attributes']['publication_type'] = 'Other'
    end
  end

  def format_month(publication, _college)
    pub_date = publication['attributes']['published_on'].present? ? Date.parse(publication['attributes']['published_on']).strftime('%B') : nil
    # if college case is still needed
    publication['attributes']['dtm'] = pub_date
  end

  def format_status(publication, college)
    # if college case is still needed
    case college
    when 'AG', 'CA', 'LA', 'BK', 'SC', 'AA', 'BC', 'LW', 'EM', 'EN', 'GV', 'IST', 'MD', 'NR', 'UC', 'AB', 'AL', 'HH', 'BA', 'ED', 'UL', 'CM', 'UE'
      if publication['attributes']['status'] =~ %r{Accepted/In press.*}
        publication['attributes']['status'] = 'Accepted'
      elsif publication['attributes']['status'] == 'E-pub ahead of print'
        publication['attributes']['status'] = 'Published'
      end
    end
  end

  def format_year(publication)
    pub_year = publication['attributes']['published_on'].present? ? Date.parse(publication['attributes']['published_on']).strftime('%Y') : nil
    if pub_year.nil?
      publication['attributes']['dty'] = nil
    elsif pub_year.length > 4
      publication['attributes']['dty'] = pub_year[0..3].to_i
      pub_year = pub_year[0..3]
      publication['attributes']['dty'] = if (pub_year.to_i >= 1950) && (pub_year.to_i <= Date.current.year + 5)
                                           pub_year.to_i
                                         end
    else
      publication['attributes']['dty'] = pub_year.to_i
    end
  end

  def format_day(publication)
    pub_day = publication['attributes']['published_on'].present? ? Date.parse(publication['attributes']['published_on']).strftime('%-d') : nil
    publication['attributes']['dtd'] = if pub_day.nil?
                                         nil
                                       else
                                         pub_day.to_i
                                       end
  end
end
