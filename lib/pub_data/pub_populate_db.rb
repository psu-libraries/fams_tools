require 'pub_data/get_pub_data'

class PubPopulateDB

  def populate(pub_hash)
    pub_hash.each do |k, user_pubs|

      faculty = Faculty.find_by(access_id: k)

      user_pubs["data"].each do |pub|

        begin
          publication = Publication.create(pure_ids:        pub["pure_ids"],
                                           ai_ids:          pub["activity_insight_ids"], 
                                           title:           pub["attributes"]["title"],
                                           volume:          pub["attributes"]["volume"],
                                           dty:             pub["attributes"]["dty"],
                                           dtd:             pub["attributes"]["dtd"],
                                           journal_title:   pub["attributes"]["journal_title"],
                                           page_range:      pub["attributes"]["page_range"],
                                           edition:         pub["attributes"]["edition"],
                                           abstract:        pub["attributes"]["abstract"],
                                           secondary_title: pub["attributes"]["secondary_title"],
                                           citation_count:  pub["attributes"]["citation_count"],
                                           authors_et_al:   pub["attributes"]["authors_et_al"]
                                           )

        rescue ActiveRecord::RecordNotUnique
          publication = Publication.find_by(pure_id: pub["pure_ids"])
        end

        pub["attributes"]["contributors"].each do |person|

          ExternalAuthor.create(publication: publication,
                                f_name:      person["first_name"],
                                m_name:      person["middle_name"],
                                l_name:      person["last_name"]
                                )
        end

        PublicationFacultyLink.create(faculty:     faculty,
                                      publication: publication,
                                      status:      pub["attributes"]["status"],
                                      category:    pub["attributes"]["publication_type"],
                                      dtm:         pub["attributes"]["dtm"])
      end
    end
  end

end
