class GetPurePublishers
  attr_accessor :uuids, :journals_xmls

  def initialize
    @uuids = Publication.pluck(:journal_uuid)
    @journals_xmls = {}
  end

  def call
    get_journals
    populate_db(journals_xmls)
  end

  private

  def get_journals
    headers = {"Accept" => "application/xml", "api-key" => "#{Rails.application.config_for(:pure)[:api_key]}"}
    uuids.each do |uuid|
      url = "https://pennstate.pure.elsevier.com/ws/api/511/journals/#{uuid}"
      response = HTTParty.get url, :headers => headers, :timeout => 100
      journals_xmls[uuid] = response
    end
  end

  def populate_db(journals_xmls)
    journals_xmls.each do |uuid, xml|
      noko_obj = Nokogiri::XML.parse(xml.to_s)
      Publication.where(journal_uuid: uuid).each do |publication|
        publication.update(publisher: noko_obj.xpath('journal//publisher//name').text)
      end
    end
  end
end
