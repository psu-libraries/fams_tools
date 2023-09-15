class PubData::GetPubData
  class MDBError < StandardError; end
  attr_accessor :user_ids, :pub_json, :pub_hash

  def initialize(college)
    @user_ids = Faculty.where(college: college.to_s).pluck(:access_id) unless college == 'All Colleges'
    @user_ids = Faculty.pluck(:access_id) if college == 'All Colleges'
    @pub_json = []
    @pub_hash = []
  end

  def call(pub_populate_obj)
    user_ids.each_slice(100) do |batch|
      headers = { 'Accept' => 'application/json', 'Content-Type' => 'application/json',
                  'X-API-Key' => "#{Rails.application.config_for(:activity_insight)['metadata_db'][:key]}" }
      url = 'https://metadata.libraries.psu.edu/v1/users/publications'
      @pub_json = HTTParty.post(url, body: "#{batch}", headers:, timeout: 200)
      json_to_hash(pub_json)
      # puts pub_hash
      format(pub_hash)
      pub_populate_obj.populate(pub_hash)
    end
  end

  private

  def format(pub_hash)
    pub_hash.each do |k, v|
      college = Faculty.find_by(access_id: k).college
      v['data'].each do |publication|
        format_type(publication, college)
        format_month(publication, college)
        format_status(publication, college)
        format_year(publication)
        format_day(publication)
      end
    end
  end

  def json_to_hash(pub_json)
    raise MDBError, pub_json['message'] if [401, 400, 403, 404, 500, 501, 502, 503].include? pub_json['code']

    @pub_hash = JSON.parse(pub_json.body)
  end

  def format_type(publication, college)
    pub_type = publication['attributes']['publication_type']
    case college
    when 'CA', 'BK', 'LW', 'GV', 'MD', 'AB', 'AA', 'BA', 'BC', 'UC', 'AL', 'LA', 'NR', 'IST'
      if ['Article', 'Review Article', 'Review article', 'Journal Article',
          'Academic Journal Article'].include?(pub_type)
        publication['attributes']['publication_type'] = 'Journal Article, Academic Journal'
      elsif pub_type == 'Conference article'
        publication['attributes']['publication_type'] = 'Conference Proceeding'
      elsif ['Comment/debate', 'Letter', 'Short survey', 'Editorial'].include?(pub_type)
        publication['attributes']['publication_type'] = 'Other'
      end
    when 'EM', 'AG', 'EN', 'HH', 'ED', 'UL', 'CM', 'UE', 'SC'
      if ['Article', 'Review Article', 'Review article', 'Journal Article, Academic Journal'].include?(pub_type)
        publication['attributes']['publication_type'] = 'Journal Article'
      elsif pub_type == 'Conference article'
        publication['attributes']['publication_type'] = 'Conference Proceeding'
      elsif ['Comment/debate', 'Letter', 'Short survey', 'Editorial'].include?(pub_type)
        publication['attributes']['publication_type'] = 'Other'
      elsif pub_type == 'Book/Film/Article review'
        publication['attributes']['publication_type'] = 'Reviews, Book'
      end
    end
  end

  def format_month(publication, college)
    pub_date = Date.parse(publication['attributes']['published_on']).strftime('%B')
    case college
    when 'AG', 'ED', 'CA', 'BK', 'SC', 'AA', 'BA', 'LW', 'EM', 'EN', 'GV', 'HH', 'MD', 'UC', 'AB', 'AL', 'BC'
      publication['attributes']['dtm'] = case pub_date
                                         when 'January'
                                           'January (1st Quarter/Winter)'
                                         when 'April'
                                           'April (2nd Quarter/Spring)'
                                         when 'July'
                                           'July (3rd Quarter/Summer)'
                                         when 'October'
                                           'October (4th Quarter/Autumn)'
                                         else
                                           pub_date
                                         end
    end
  end

  def format_status(publication, college)
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
    pub_year = Date.parse(publication['attributes']['published_on']).strftime('%Y')
    if pub_year.length > 4
      publication['attributes']['dty'] = pub_year[0..3].to_i
      pub_year = pub_year[0..3]
    end
    publication['attributes']['dty'] = if (pub_year.to_i >= 1950) && (pub_year.to_i <= Date.current.year + 5)
                                         pub_year.to_i
                                       end
  end

  def format_day(publication)
    pub_day = Date.parse(publication['attributes']['published_on']).strftime('%-d')
    publication['attributes']['dtd'] = pub_day.to_i
  end
end
