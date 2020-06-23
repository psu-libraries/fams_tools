require 'rails_helper'

describe WorkOutputs do
  let!(:publication_listing) { FactoryBot.create :publication_listing }
  let!(:work1) { FactoryBot.create :work, publication_listing: publication_listing }
  let!(:work2) { FactoryBot.create :work, publication_listing: publication_listing, author: nil }
  let!(:publication_listing_2) { FactoryBot.create :publication_listing }
  let!(:work3) { FactoryBot.create :work, publication_listing: publication_listing_2, contype: 'presentations' }
  let!(:work4) { FactoryBot.create :work, publication_listing: publication_listing_2, contype: 'presentations', author: nil }
  let(:works) { Work.where(publication_listing: publication_listing.id) }
  let(:works2) { Work.where(publication_listing: publication_listing_2.id) }
  let(:pub_csv) do
    "USERNAME,TITLE,VOLUME,EDITION,PAGENUM,DTY_END,DTM_END,DTD_END,JOURNAL_NAME,CONTYPE,EDITORS,INSTITUTION,PUBCTYST,COMMENT,INTELLCONT_AUTH_1_FNAME,INTELLCONT_AUTH_1_MNAME,INTELLCONT_AUTH_1_LNAME\ntest123,Test,1,2,1-2,2001,9,30,Test Journal,Journal Article,\"Frank, Zappa\",PSU,State College,Some note,Jim,\"\",Bob\ntest123,Test,1,2,1-2,2001,9,30,Test Journal,Journal Article,\"Frank, Zappa\",PSU,State College,Some note,\"\",\"\",\"\",\"\"\n"
  end
  let(:pres_csv) do
    "USERNAME,TITLE,EDITION,PAGENUM,DTY_END,DTM_END,DTD_END,JOURNAL_NAME,CONTYPE,EDITORS,INSTITUTION,PUBCTYST,COMMENT,INTELLCONT_AUTH_1_FNAME,INTELLCONT_AUTH_1_MNAME,INTELLCONT_AUTH_1_LNAME\ntest123,Test,2,1-2,2001,9,30,Test Journal,Journal Article,\"Frank, Zappa\",PSU,State College,Some note,Jim,\"\",Bob\ntest123,Test,2,1-2,2001,9,30,Test Journal,Journal Article,\"Frank, Zappa\",PSU,State College,Some note,\"\",\"\",\"\",\"\"\n"
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
      it 'returns a properly formatted xlsx file' do
        expect(XLSXOutput.new(works).output(Axlsx::Package.new.workbook).workbook.worksheets.first.rows.first.first.row.collect { |n| n.value }).to eq ["USERNAME", "TITLE", "VOLUME", "EDITION", "PAGENUM", "DTY_END", "DTM_END", "DTD_END", "JOURNAL_NAME", "CONTYPE", "EDITORS", "INSTITUTION", "PUBCTYST", "COMMENT", "INTELLCONT_AUTH_1_FNAME", "INTELLCONT_AUTH_1_MNAME", "INTELLCONT_AUTH_1_LNAME"]
        expect(XLSXOutput.new(works).output(Axlsx::Package.new.workbook).workbook.worksheets.first.rows.second.first.row.collect { |n| n.value }).to eq ["test123", "Test", 1, 2, "1-2", 2001, 9, 30, "Test Journal", "Journal Article", "Frank, Zappa", "PSU", "State College", "Some note", "Jim", "", "Bob"]
      end
    end
  end
end