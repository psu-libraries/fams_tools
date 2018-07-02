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

      publication = Publication.create(faculty:       faculty,
                                       title:         v['title'],
                                       type:          v['type'],
                                       volume:        v['volume'],
                                       dty:           v['dty'],
                                       dtm:           v['dtm'],
                                       dtd:           v['dtd'],
                                       journal_title: v['journalTitle'],
                                       journal_issn:  v['journalIssn'],
                                       journal_num:   v['journalNum'],
                                       pages:         v['pages']
                                      )

      ExternalAuthor.create(publication: publication,
                            f_name: v['fName'],
                            m_name: v['mName'],
                            l_name: v['lName'],
                            role:   v['role']
                           )

    end
  end

end
