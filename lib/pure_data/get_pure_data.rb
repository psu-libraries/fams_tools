class GetPureData
  attr_accessor :pure_ids, :pure_xmls, :pure_hash

  def initialize
    @pure_ids = PureId.all
    @pure_xmls = {}
    @pure_hash = {}
  end

  def call
    get_pub_xmls
    xml_to_hash(pure_xmls)
    format(pure_hash)
  end

  private

  def format(pure_hash)
    pure_hash.each do |k,v|
      college = Faculty.find_by(access_id: k).college
      v.each do |publication|
        format_type(publication, college)
        format_month(publication, college)
        format_status(publication, college)
        format_reviewed(publication)
        format_year(publication)
        format_day(publication)
      end
    end
  end

  def get_pub_xmls
    headers = {"Accept" => "application/xml", "api-key" => "#{Rails.application.config_for(:pure)[:api_key]}"}
    pure_ids.each do |id|
      url = "https://pennstate.pure.elsevier.com/ws/api/511/persons/#{id.pure_id}/research-outputs"
      response = HTTParty.get url, :headers => headers, :timeout => 100
      pure_xmls[id.faculty.access_id] = response
    end
  end

  def format_type(publication, college)
    case college
    when 'CA', 'BK', 'LW', 'GV', 'MD', 'AB', 'AA', 'BA', 'BC', 'UC', 'AL'
      if publication[:category] == 'Article' || publication[:category] == 'Review Article' || publication[:category] == "Review article"
        publication[:category] = 'Journal Article, Academic Journal'
      elsif publication[:category] == 'Conference article'
        publication[:category] = 'Conference Proceeding'
      elsif publication[:category] == 'Comment/debate' || publication[:category] == 'Letter' || publication[:category] == 'Short survey' || publication[:category] == 'Editorial'
        publication[:category] = 'Other'
      end
    when 'EM', 'AG', 'EN', 'HH', 'ED', 'UL', 'CM', 'UE'
      if publication[:category] == 'Article' || publication[:category] == 'Review Article' || publication[:category] == "Review article"
        publication[:category] = 'Journal Article'
      elsif publication[:category] == 'Conference article'
        publication[:category] = 'Conference Proceeding'
      elsif publication[:category] == 'Comment/debate' || publication[:category] == 'Letter' || publication[:category] == 'Short survey' || publication[:category] == 'Editorial'
        publication[:category] = 'Other'
      end
    end
  end

  def format_month(publication, college)
    publication[:dtm] = Date::MONTHNAMES[publication[:dtm].to_i]
    case college
    when 'AG', 'ED', 'CA', 'BK', 'SC', 'AA', 'BA', 'LW', 'EM', 'EN', 'GV', 'HH', 'MD', 'UC', 'AB', 'AL', 'BC'
      case publication[:dtm]
      when 'January'
        publication[:dtm] = 'January (1st Quarter/Winter)'
      when 'April'
        publication[:dtm] = 'April (2nd Quarter/Spring)'
      when 'July'
        publication[:dtm] = 'July (3rd Quarter/Summer)'
      when 'October'
        publication[:dtm] = 'October (4th Quarter/Autumn)'
      end
    end
  end

  def format_reviewed(publication)
    case publication[:peerReview]
    when 'true'
      publication[:peerReview] = 'Yes'
    when 'false'
      publication[:peerReview] = 'No'
    else
      publication[:peerReview] = 'Unknown'
    end
  end

  def format_status(publication, college)
    case college
    when 'AG', 'CA', 'LA', 'BK', 'SC', 'AA', 'BC', 'LW', 'EM', 'EN', 'GV', 'IST', 'MD', 'NR', 'UC', 'AB', 'AL', 'HH', 'BA', 'ED', 'UL', 'CM', 'UE'
      if publication[:status] =~ /Accepted\/In press.*/
        publication[:status] = 'Accepted'
      elsif publication[:status] == 'E-pub ahead of print'
        publication[:status] = 'Published'
      end
    end
  end

  def format_year(publication)
    if publication[:dty].length > 4
      publication[:dty] = publication[:dty][0..3]
    end
    unless (publication[:dty].to_i >= 1950) && (publication[:dty].to_i <= Date.current.year + 5)
      publication[:dty] = nil
    end
  end

  def format_day(publication)
    if publication[:dtd].to_i > 31 || publication[:dtd].to_i < 1
      publication[:dtd] = nil
    end
    if college = 'CM'
      publication[:dtd] = nil
    end
  end

  def xml_to_hash(pure_xmls)
    pure_xmls.each do |k,xml|
      noko_obj = Nokogiri::XML.parse(xml.to_s)
      noko_obj.xpath('result//contributionToJournal').each do |publication|
        if pure_hash[k]
          pure_hash[k] << {:title => publication.xpath('title').text,
                           :category => publication.xpath('type').text,
                           :volume => publication.xpath('volume').text,
                           :status => publication.xpath('publicationStatuses//publicationStatus//publicationStatus').text,
                           :dty => publication.xpath('publicationStatuses//publicationDate//year').text,
                           :dtm => publication.xpath('publicationStatuses//publicationDate//month').text,
                           :dtd => publication.xpath('publicationStatuses//publicationDate//day').text,
                           :persons => publication.xpath('personAssociations//personAssociation').collect {
                             |x| {:fName => x.xpath('name//firstName').text,
                                  :mName => x.xpath('name//middleName').text, 
                                  :lName => x.xpath('name//lastName').text,
                                  :role => x.xpath('personRole').text,
                                  :extOrg => x.xpath('externalOrganisations//externalOrganisation//name').text}
                           },
                           :journalTitle => publication.xpath('journalAssociation//title').text,
                           :journalIssn => publication.xpath('journalAssociation//issn').text,
                           :journalNum => publication.xpath('journalNumber').text,
                           :pages => publication.xpath('pages').text,
                           :articleNumber => publication.xpath('articleNumber').text,
                           :peerReview => publication.xpath('peerReview').text,
                           :url => publication.xpath('electronicVersions//electronicVersion//doi').text}
        else
          pure_hash[k] =  [{:title => publication.xpath('title').text,
                           :category => publication.xpath('type').text,
                           :volume => publication.xpath('volume').text,
                           :status => publication.xpath('publicationStatuses//publicationStatus//publicationStatus').text,
                           :dty => publication.xpath('publicationStatuses//publicationDate//year').text,
                           :dtm => publication.xpath('publicationStatuses//publicationDate//month').text,
                           :dtd => publication.xpath('publicationStatuses//publicationDate//day').text,
                           :persons => publication.xpath('personAssociations//personAssociation').collect {
                             |x| {:fName => x.xpath('name//firstName').text,
                                  :mName => x.xpath('name//middleName').text, 
                                  :lName => x.xpath('name//lastName').text,
                                  :role => x.xpath('personRole').text,
                                  :extOrg => x.xpath('externalOrganisations//externalOrganisation//name').text}
                           },
                           :journalTitle => publication.xpath('journalAssociation//title').text,
                           :journalIssn => publication.xpath('journalAssociation//issn').text,
                           :journalNum => publication.xpath('journalNumber').text,
                           :pages => publication.xpath('pages').text,
                           :articleNumber => publication.xpath('articleNumber').text,
                           :peerReview => publication.xpath('peerReview').text,
                           :url => publication.xpath('electronicVersions//electronicVersion//doi').text}]
        end
      end
    end
  end

end
