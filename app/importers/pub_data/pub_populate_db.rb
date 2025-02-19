require 'pub_data/get_pub_data'

# Import designed specifically for data from Metadata database.
class PubData::PubPopulateDb
  def populate(pub_hash, user_id)
    faculty = Faculty.find_by(access_id: user_id)
    pub_hash['data'].each do |pub|
      next if pub['attributes']['activity_insight_ids'].present?
      publication = Publication.create(
                                       title: pub['attributes']['title'],
                                       # RMD has some bad data for volume, so error checking is needed
                                       volume: pub['attributes']['volume'].to_i < 5000 ? pub['attributes']['volume'] : nil,
                                       dty: pub['attributes']['dty'],
                                       dtd: pub['attributes']['dtd'],
                                       journal_title: pub['attributes']['journal_title'],
                                       page_range: pub['attributes']['page_range'],
                                       edition: pub['attributes']['edition'],
                                       abstract: pub['attributes']['abstract'],
                                       secondary_title: pub['attributes']['secondary_title'],
                                       citation_count: pub['attributes']['citation_count'],
                                       authors_et_al: pub['attributes']['authors_et_al'],
                                       rmd_id: pub['id'])

      pub['attributes']['contributors'].each do |person|
        ExternalAuthor.create(publication:,
                              f_name: person['first_name'],
                              m_name: person['middle_name'],
                              l_name: person['last_name'])
      end

      PublicationFacultyLink.create(faculty:,
                                    publication:,
                                    status: pub['attributes']['status'],
                                    category: pub['attributes']['publication_type'],
                                    dtm: pub['attributes']['dtm'])
    end
  end
end
