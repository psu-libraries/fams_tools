class WorkOutputs
  attr_reader :cv_owner, :workstype, :works

  def initialize(works)
    @works = works
    @cv_owner = Faculty.find_by(access_id: works.pluck(:username).uniq.first)
    @workstype = works.pluck(:contype).uniq.first.downcase
    # Control flow in the spreadsheet output will determine the final @header_map
    @header_map = []
  end

  # These "maps" map the data parsed from the cv parser to the headers in the spreadsheet outputs
  PRES_MAP = %i[username title journal edition year month day booktitle
                container contype doi editor institution isbn location
                note publisher retrieved tech translator unknown url].freeze

  PUB_MAP = %i[username title journal volume edition pages
                  year month day booktitle container contype doi
                  editor institution isbn location note publisher retrieved
                  tech translator unknown url].freeze

  PRES_HEADERS = %w[USERNAME TITLE journal EDITION DTY_END DTM_END
                    DTD_END booktitle NAME TYPE doi editor
                    ORG isbn LOCATION COMMENT publisher retrieved
                    tech translator unknown url].freeze

  PUB_HEADERS = %w[USERNAME TITLE journal VOLUME EDITION PAGENUM
                   DTY_END DTM_END DTD_END booktitle JOURNAL_NAME CONTYPE
                   WEB_ADDRESS EDITORS INSTITUTION ISBNISSN PUBCTYST COMMENT
                   PUBLISHER retrieved tech translator unknown url].freeze

  def output
    # Defined in subclass
  end
end
