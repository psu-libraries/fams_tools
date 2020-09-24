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
  # Note that :date in the db maps to [DTY_END, DTM_END, DTD_END] in PUB_HEADERS
  # and [DTY_START, DTM_START, DTD_START, DTY_END, DTM_END, DTD_END] in PRES_HEADERS
  PRES_MAP = %i[username contype title container location date
                edition note institution pages volume journal booktitle doi
                editors isbn publisher retrieved tech translator unknown url].freeze

  PUB_MAP = %i[username title journal volume edition pages
               date booktitle container contype doi
               editors institution isbn location note publisher retrieved
               tech translator unknown url].freeze

  PRES_HEADERS = ['USERNAME', 'TYPE', 'TITLE', 'NAME', 'LOCATION', ['DTM_START', 'DTD_START', 'DTY_START',
                  'DTM_END', 'DTD_END', 'DTY_END'], 'edition', 'COMMENT', 'institution', 'pages', 'volume',
                  'journal', 'booktitle', 'doi', 'editors', 'isbn', 'publisher', 'retrieved',
                  'tech', 'translator', 'unknown', 'url'].freeze

  PUB_HEADERS = ['USERNAME', 'TITLE', 'journal', 'VOLUME', 'EDITION', 'PAGENUM',
                 ['DTY_END', 'DTM_END', 'DTD_END'], 'booktitle', 'JOURNAL_NAME', 'CONTYPE',
                 'WEB_ADDRESS', 'EDITORS', 'INSTITUTION', 'ISBNISSN', 'PUBCTYST', 'COMMENT',
                 'PUBLISHER', 'retrieved', 'tech', 'translator', 'unknown', 'url'].freeze

  def output
    # Defined in subclass
  end
end
