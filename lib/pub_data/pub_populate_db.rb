require 'pub_data/get_pub_data'

class PubPopulateDB
  attr_accessor :pub_data

  def initialize(pub_data_obj = GetPubData.new)
    @pub_data = pub_data_obj
  end

  def populate
    pub_data.call
    pub_data.pub_hash.each do |k,v|

      faculty = Faculty.find_by(access_id: k)

      v.each do |pub|

        begin
          publication = Publication.create(pure_id:      pub["attributes"]["pure_ids"],
                                          title:         pub["attributes"]["title"],
                                          volume:        pub["attributes"]["volume"],
                                          dty:           pub["attributes"]["dty"],
                                          dtd:           pub["attributes"]["dtd"],
                                          journal_title: pub["attributes"]["journal_title"],
                                          pages:         pub["attributes"]["page_range"],
                                          publisher:     nil
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
