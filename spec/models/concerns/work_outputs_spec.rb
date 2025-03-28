require 'rails_helper'

describe WorkOutputs do
  let!(:publication_listing) { FactoryBot.create(:publication_listing) }
  let!(:work1) { FactoryBot.create(:work, publication_listing:, institution: nil) }
  let!(:work2) { FactoryBot.create(:work, publication_listing:, institution: '') }
  let!(:publication_listing_2) { FactoryBot.create(:publication_listing) }
  let!(:work3) do
    FactoryBot.create(:work, publication_listing: publication_listing_2, contype: 'Presentations',
                             date: 'September 1-30, 2011')
  end
  let!(:work4) { FactoryBot.create(:work, publication_listing: publication_listing_2, contype: 'Presentations') }
  let(:works) { Work.where(publication_listing: publication_listing.id) }
  let(:works2) { Work.where(publication_listing: publication_listing_2.id) }
  let!(:author_1) { FactoryBot.create(:author, work: work1) }
  let!(:author_2) { FactoryBot.create(:author, work: work3) }
  let!(:editor) { FactoryBot.create(:editor, work: work1) }
  let!(:editor_2) { FactoryBot.create(:editor, work: work3) }
  let(:pub_csv) do
    "USERNAME,TITLE,VOLUME,EDITION,PAGENUM,DTY_END,DTM_END,DTD_END,JOURNAL_NAME,CONTYPE,EDITORS,PUBCTYST,COMMENT,INTELLCONT_AUTH_1_FNAME,INTELLCONT_AUTH_1_MNAME,INTELLCONT_AUTH_1_LNAME\ntest123,Test,1,2,1-2,2001,9,30,Test Journal,Journal Article,#{editor.f_name} #{editor.m_name} #{editor.l_name},State College,Some note,#{author_1.f_name},#{author_1.m_name},#{author_1.l_name}\ntest123,Test,1,2,1-2,2001,9,30,Test Journal,Journal Article,\"\",State College,Some note,\"\",\"\",\"\",\"\"\n"
  end
  let(:pres_csv) do
    "USERNAME,TYPE,TITLE,NAME,LOCATION,DTM_START,DTD_START,DTY_START,DTM_END,DTD_END,DTY_END,edition,COMMENT,institution,pages,volume,editors,PRESENT_AUTH_1_FNAME,PRESENT_AUTH_1_MNAME,PRESENT_AUTH_1_LNAME\ntest123,Presentations,Test,Test Journal,State College,2011,9,1,2011,9,30,2,Some note,PSU,1-2,1,#{editor_2.f_name} #{editor_2.m_name} #{editor_2.l_name},#{author_2.f_name},#{author_2.m_name},#{author_2.l_name}\ntest123,Presentations,Test,Test Journal,State College,2001,9,30,\"\",\"\",\"\",2,Some note,PSU,1-2,1,\"\",\"\",\"\",\"\",\"\"\n"
  end

  # These subclasses of WorkOutputs all have different definitions of #output
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

  describe '#XlsxOutput' do
    describe '#output' do
      context 'when publications' do
        let(:first_row_collect) do
          XlsxOutput.new(works).output(Axlsx::Package.new.workbook).workbook.worksheets.first.rows.first.first.row.collect do |n|
            n.value
          end
        end
        let(:second_row_collect) do
          XlsxOutput.new(works).output(Axlsx::Package.new.workbook).workbook.worksheets.first.rows.second.first.row.collect do |n|
            n.value
          end
        end

        # TODO: rubyzip is not compatible with ruby 3.4 at this time, causing xlsx download to fail. Sticking to csv download only until this is resolved
        xit 'returns a properly formatted xlsx file' do
          expect(first_row_collect).to eq %w[USERNAME TITLE VOLUME EDITION PAGENUM DTY_END DTM_END
                                             DTD_END JOURNAL_NAME CONTYPE EDITORS PUBCTYST
                                             COMMENT INTELLCONT_AUTH_1_FNAME INTELLCONT_AUTH_1_MNAME
                                             INTELLCONT_AUTH_1_LNAME]
          expect(second_row_collect).to eq ['test123', 'Test', 1, 2, '1-2', 2001, 9, 30, 'Test Journal',
                                            'Journal Article', "#{editor.f_name} #{editor.m_name} #{editor.l_name}",
                                            'State College', 'Some note', "#{author_1.f_name}", 'Person', 'User']
        end
      end

      context 'when presentations' do
        let(:first_row_collect) do
          XlsxOutput.new(works2).output(Axlsx::Package.new.workbook).workbook.worksheets.first.rows.first.first.row.collect do |n|
            n.value
          end
        end
        let(:second_row_collect) do
          XlsxOutput.new(works2).output(Axlsx::Package.new.workbook).workbook.worksheets.first.rows.second.first.row.collect do |n|
            n.value
          end
        end

        # TODO: rubyzip is not compatible with ruby 3.4 at this time, causing xlsx download to fail. Sticking to csv download only until this is resolved
        xit 'returns a properly formatted xlsx file' do
          expect(first_row_collect).to eq %w[USERNAME TYPE TITLE NAME LOCATION DTM_START DTD_START
                                             DTY_START DTM_END DTD_END DTY_END edition COMMENT
                                             institution pages volume editors PRESENT_AUTH_1_FNAME
                                             PRESENT_AUTH_1_MNAME PRESENT_AUTH_1_LNAME]
          expect(second_row_collect).to eq ['test123', 'Presentations', 'Test', 'Test Journal', 'State College', 2011,
                                            9, 1, 2011, 9, 30, 2, 'Some note', 'PSU', '1-2', 1,
                                            "#{editor_2.f_name} #{editor_2.m_name} #{editor_2.l_name}",
                                            "#{author_2.f_name}", 'Person', 'User']
        end
      end
    end
  end
end
