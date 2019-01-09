require 'rails_helper'

describe Publication, type: :model do
  describe 'columns' do
    it { is_expected.to have_db_column(:id).of_type(:integer).with_options(null: false) }
    it { is_expected.to have_db_column(:pure_ids).of_type(:string) }
    it { is_expected.to have_db_column(:title).of_type(:text) }
    it { is_expected.to have_db_column(:volume).of_type(:integer) }
    it { is_expected.to have_db_column(:dty).of_type(:integer) }
    it { is_expected.to have_db_column(:dtd).of_type(:integer) }
    it { is_expected.to have_db_column(:journal_title).of_type(:string) }
    it { is_expected.to have_db_column(:issue).of_type(:integer) }
    it { is_expected.to have_db_column(:page_range).of_type(:string) }
    it { is_expected.to have_db_column(:articleNumber).of_type(:integer) }
    it { is_expected.to have_db_column(:publisher).of_type(:string) }
    it { is_expected.to have_db_column(:edition).of_type(:integer) }
    it { is_expected.to have_db_column(:abstract).of_type(:text) }
    it { is_expected.to have_db_column(:secondary_title).of_type(:text) }
    it { is_expected.to have_db_column(:citation_count).of_type(:integer) }
    it { is_expected.to have_db_column(:authors_et_al).of_type(:boolean) }
    it { is_expected.to have_db_column(:ai_ids).of_type(:string) }
    it { is_expected.to have_db_column(:web_address).of_type(:string) }
    it { is_expected.to have_db_column(:editors).of_type(:text) }
    it { is_expected.to have_db_column(:institution).of_type(:string) }
    it { is_expected.to have_db_column(:isbnissn).of_type(:string) }
    it { is_expected.to have_db_column(:pubctyst).of_type(:string) }
    it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
    it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }

    it { is_expected.to have_db_index([:pure_ids, :ai_ids]).unique(true) }
  end

  describe 'associations' do
    it { is_expected.to have_many(:external_authors) }
    it { is_expected.to have_many(:publication_faculty_links) }
    it { is_expected.to have_many(:faculties) }
  end

  describe 'serializations' do
    it { is_expected.to serialize(:pure_ids) }
    it { is_expected.to serialize(:ai_ids) }
    it { is_expected.to serialize(:editors) }
  end
end
