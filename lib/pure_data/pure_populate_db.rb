require 'pure_data/get_pure_data'

class PurePopulateDB
  attr_accessor :pure_data

  def initialize(pure_data_obj = GetPureData.new)
    @pure_data = pure_data_obj
  end

  def populate
    pure_data.call
    puts pure_data.pure_hash
    pure_data.pure_hash.each do |k,v|

      faculty = Faculty.find_by(access_id: k)

      v.each do |pub|

        publication = Publication.create(faculty:       faculty,
                                         title:         pub[:title],
                                         category:      pub[:type],
                                         volume:        pub[:volume],
                                         dty:           pub[:dty],
                                         dtm:           pub[:dtm],
                                         dtd:           pub[:dtd],
                                         journal_title: pub[:journalTitle],
                                         journal_issn:  pub[:journalIssn],
                                         journal_num:   pub[:journalNum],
                                         pages:         pub[:pages]
                                         )

        pub[:persons].each do |person|

          ExternalAuthor.create(publication: publication,
                                f_name:      person[:fName],
                                m_name:      person[:mName],
                                l_name:      person[:lName],
                                role:        person[:role]
                                )
        end
      end
    end
  end

end
