require 'pure_data/get_pure_data'

class PurePopulateDB
  attr_accessor :pure_data

  def initialize(pure_data_obj = GetPureData.new)
    @pure_data = pure_data_obj
  end

  def populate
    pure_data.call
    pure_data.pure_hash.each do |k,v|

      faculty = Faculty.find_by(access_id: k)

      v.each do |pub|

        begin
          publication = Publication.create(pure_id:       pub[:pure_id],
                                          title:         pub[:title],
                                          status:        pub[:status],
                                          category:      pub[:category],
                                          volume:        pub[:volume],
                                          dty:           pub[:dty],
                                          dtm:           pub[:dtm],
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
                                      publication: publication)
      end
    end
  end

end
