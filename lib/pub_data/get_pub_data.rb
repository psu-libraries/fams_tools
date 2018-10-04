class GetPubData
  attr_accessor :user_ids, :pub_json, :pub_hash

  def initialize
    @user_ids = Faculty.pluck(:access_id)
    @pub_json = {}
    @pub_hash = {}
  end

  def call
    get_pub_json
    json_to_hash(pub_json)
    format(pub_hash)
  end

  private

  def format(pub_hash)
    pub_hash.each do |k,v|
      college = Faculty.find_by(access_id: k).college
      v["data"].each do |publication|
        format_type(publication, college)
        format_month(publication, college)
        format_status(publication, college)
        format_year(publication)
        format_day(publication)
      end
    end
  end

  def get_pub_json
    headers = {"Accept" => "application/xml", "api-key" => "#{Rails.application.config_for(:pure)[:api_key]}"}
    url = "https://stage.metadata.libraries.psu.edu/v1/users/publications"
    @pub_json = HTTParty.post url, :body => user_ids, :headers => headers, :timeout => 100
  end

  def json_to_hash(pub_json)
    @pub_hash = JSON.parse(pub_json)
  end

  def format_type(publication, college)
    pub_type = publication["attributes"]["publication_type"]
    case college
    when 'CA', 'BK', 'LW', 'GV', 'MD', 'AB', 'AA', 'BA', 'BC', 'UC', 'AL', 'LA', 'NR', 'IST'
      if pub_type == 'Article' || pub_type == 'Review Article' || pub_type == "Review article" || pub_type == "Journal Article"
        pub_type = 'Journal Article, Academic Journal'
      elsif pub_type == 'Conference article'
        pub_type = 'Conference Proceeding'
      elsif pub_type == 'Comment/debate' || pub_type == 'Letter' || pub_type == 'Short survey' || pub_type == 'Editorial'
        pub_type = 'Other'
      end
    when 'EM', 'AG', 'EN', 'HH', 'ED', 'UL', 'CM', 'UE', 'SC'
      if pub_type == 'Article' || pub_type == 'Review Article' || pub_type == "Review article" || pub_type == 'Journal Article, Academic Journal'
        pub_type = 'Journal Article'
      elsif pub_type == 'Conference article'
        pub_type = 'Conference Proceeding'
      elsif pub_type == 'Comment/debate' || pub_type == 'Letter' || pub_type == 'Short survey' || pub_type == 'Editorial'
        pub_type = 'Other'
      elsif pub_type == 'Book/Film/Article review'
        pub_type = 'Reviews, Book'
      end
    end
  end

  def format_month(publication, college)
    pub_date = Date.parse(publication["attributes"]["published_on"]).strftime("%B")
    case college
    when 'AG', 'ED', 'CA', 'BK', 'SC', 'AA', 'BA', 'LW', 'EM', 'EN', 'GV', 'HH', 'MD', 'UC', 'AB', 'AL', 'BC'
      case pub_date
      when 'January'
        publication["attributes"]["dtm"] = 'January (1st Quarter/Winter)'
      when 'April'
        publication["attributes"]["dtm"] = 'April (2nd Quarter/Spring)'
      when 'July'
        publication["attributes"]["dtm"] = 'July (3rd Quarter/Summer)'
      when 'October'
        publication["attributes"]["dtm"] = 'October (4th Quarter/Autumn)'
      else
        publication["attributes"]["dtm"] = pub_date
      end
    end
  end

  def format_status(publication, college)
    case college
    when 'AG', 'CA', 'LA', 'BK', 'SC', 'AA', 'BC', 'LW', 'EM', 'EN', 'GV', 'IST', 'MD', 'NR', 'UC', 'AB', 'AL', 'HH', 'BA', 'ED', 'UL', 'CM', 'UE'
      if publication["attributes"]["status"] =~ /Accepted\/In press.*/
        publication["attributes"]["status"] = 'Accepted'
      elsif publication["attributes"]["status"] == 'E-pub ahead of print'
        publication["attributes"]["status"] = 'Published'
      end
    end
  end

  def format_year(publication)
    pub_year = Date.parse(publication["attributes"]["published_on"]).strftime("%Y")
    if pub_year.length > 4
      publication["attributes"]["dty"] = pub_year[0..3]
      pub_year = pub_year[0..3]
    end
    unless (pub_year.to_i >= 1950) && (pub_year.to_i <= Date.current.year + 5)
      publication["attributes"]["dty"] = nil
    else
      publication["attributes"]["dty"] = pub_year
    end
  end

  def format_day(publication)
    pub_day = Date.parse(publication["attributes"]["published_on"]).strftime("%-d")
    publication["attributes"]["dtd"] = pub_day
  end

end
