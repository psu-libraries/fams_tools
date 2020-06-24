require 'rails_helper'

describe WorkOutputs do
  let!(:publication_listing) { FactoryBot.create :publication_listing }
  let!(:work1) { FactoryBot.create :work, publication_listing: publication_listing }
  let!(:work2) { FactoryBot.create :work, publication_listing: publication_listing, author: nil }
  let!(:publication_listing_2) { FactoryBot.create :publication_listing }
  let!(:work3) { FactoryBot.create :work, publication_listing: publication_listing_2, contype: 'Presentations' }
  let!(:work4) { FactoryBot.create :work, publication_listing: publication_listing_2, contype: 'Presentations',
                                                                                            author: nil }
  let(:works) { Work.where(publication_listing: publication_listing.id) }
  let(:works2) { Work.where(publication_listing: publication_listing_2.id) }
  let(:pub_csv) do
    "USERNAME,TITLE,VOLUME,EDITION,PAGENUM,DTY_END,DTM_END,DTD_END,JOURNAL_NAME,CONTYPE,EDITORS,INSTITUTION,PUBCTYST,COMMENT,INTELLCONT_AUTH_1_FNAME,INTELLCONT_AUTH_1_MNAME,INTELLCONT_AUTH_1_LNAME\ntest123,Test,1,2,1-2,2001,9,30,Test Journal,Journal Article,\"Frank, Zappa\",PSU,State College,Some note,Jim,\"\",Bob\ntest123,Test,1,2,1-2,2001,9,30,Test Journal,Journal Article,\"Frank, Zappa\",PSU,State College,Some note,\"\",\"\",\"\",\"\"\n"
  end
  let(:pres_csv) do
    "USERNAME,TYPE,TITLE,NAME,LOCATION,DTM_END,DTD_END,DTY_END,edition,note,institution,pages,volume,editor,PRESENT_AUTH_1_FNAME,PRESENT_AUTH_1_MNAME,PRESENT_AUTH_1_LNAME\ntest123,Presentations,Test,Test Journal,State College,9,30,2001,2,Some note,PSU,1-2,1,\"Frank, Zappa\",Jim,\"\",Bob\ntest123,Presentations,Test,Test Journal,State College,9,30,2001,2,Some note,PSU,1-2,1,\"Frank, Zappa\",\"\",\"\",\"\",\"\"\n"
  end

  # These subclasses of WorkOutputs all have different implementations of #output
  describe '#SpreadsheetOutput' do
    describe '#output' do
      context 'when publications' do
        it 'returns a properly formatted csv file' do
          expect(SpreadsheetOutput.new(works).output.to_csv).to eq pub_csv
        end
      end
      context 'when presentations' do
        it 'returns a properly formatted csv file' do
          expect(SpreadsheetOutput.new(works2).output.to_csv).to eq pres_csv
        end
      end
    end
  end

  describe '#BibtexOutput' do
    describe '#output' do
      it 'returns a properly formatted bibtex file' do
        expect(BibtexOutput.new(works).output[1].key).to eq "unknown2001a"
        expect(BibtexOutput.new(works).output.length).to eq 2
      end
    end
  end

  describe '#XLSXOutput' do
    describe '#output' do
      context 'when publications' do
        let(:first_row_collect) {
          XLSXOutput.new(works).output(Axlsx::Package.new.workbook).workbook.worksheets.first.rows.first.first.row.collect { |n| n.value }
        }
        let(:second_row_collect) {
          XLSXOutput.new(works).output(Axlsx::Package.new.workbook).workbook.worksheets.first.rows.second.first.row.collect { |n| n.value }
        }
        it 'returns a properly formatted xlsx file' do
          expect(first_row_collect).to eq ["USERNAME", "TITLE", "VOLUME", "EDITION", "PAGENUM", "DTY_END", "DTM_END",
                                           "DTD_END", "JOURNAL_NAME", "CONTYPE", "EDITORS", "INSTITUTION", "PUBCTYST",
                                           "COMMENT", "INTELLCONT_AUTH_1_FNAME", "INTELLCONT_AUTH_1_MNAME",
                                           "INTELLCONT_AUTH_1_LNAME"]
          expect(second_row_collect).to eq ["test123", "Test", 1, 2, "1-2", 2001, 9, 30, "Test Journal",
                                            "Journal Article", "Frank, Zappa", "PSU", "State College",
                                            "Some note", "Jim", "", "Bob"]
        end
      end
      context 'when presentations' do
        let(:first_row_collect) {
          XLSXOutput.new(works2).output(Axlsx::Package.new.workbook).workbook.worksheets.first.rows.first.first.row.collect { |n| n.value }
        }
        let(:second_row_collect) {
          XLSXOutput.new(works2).output(Axlsx::Package.new.workbook).workbook.worksheets.first.rows.second.first.row.collect { |n| n.value }
        }
        it 'returns a properly formatted xlsx file' do
          expect(first_row_collect).to eq ['USERNAME', 'TYPE', 'TITLE', 'NAME', 'LOCATION', 'DTM_END', 'DTD_END',
                                           'DTY_END', 'edition', 'note', 'institution', 'pages', 'volume',
                                           'editor', 'PRESENT_AUTH_1_FNAME', 'PRESENT_AUTH_1_MNAME',
                                           'PRESENT_AUTH_1_LNAME']
          expect(second_row_collect).to eq ["test123", "Presentations", "Test", "Test Journal", "State College", 9,
                                            30, 2001, 2, "Some note", "PSU", "1-2", 1, "Frank, Zappa", "Jim", "", "Bob"]
        end
      end
    end
  end
end