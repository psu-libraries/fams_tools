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
          publication = Publication.create(pure_id:       pub[:pure_id],
                                          title:         pub[:title],
                                          volume:        pub[:volume],
                                          dty:           pub[:dty],
                                          dtd:           pub[:dtd],
                                          journal_title: pub[:journalTitle],
                                          journal_issn:  pub[:journalIssn],
                                          journal_num:   pub[:journalNum],
                                          journal_uuid:  pub[:journaluuid],
                                          pages:         pub[:pages],
                                          articleNumber: pub[:articleNumber],
                                          peerReview:    pub[:peerReview],
                                          url:           pub[:url],
                                          publisher:     nil
                                          )

        rescue ActiveRecord::RecordNotUnique
          publication = Publication.find_by(pure_id: pub[:pure_id])
        end

        pub[:persons].each do |person|

          ExternalAuthor.create(publication: publication,
                                f_name:      person[:fName],
                                m_name:      person[:mName],
                                l_name:      person[:lName],
                                role:        person[:role],
                                extOrg:      person[:extOrg]
                                )
        end

        PublicationFacultyLink.create(faculty:     faculty,
                                      publication: publication,
                                      status:      pub[:status],
                                      category:    pub[:category],
                                      dtm:         pub[:dtm])
      end
    end
  end

end
