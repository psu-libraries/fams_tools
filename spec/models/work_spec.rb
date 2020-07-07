require 'rails_helper'

describe Work, type: :model do
  describe 'columns' do
    it { is_expected.to have_db_column(:id).of_type(:integer).with_options(null: false) }
    it { is_expected.to have_db_column(:publication_listing_id).of_type(:integer) }
    it { is_expected.to have_db_column(:author).of_type(:text) }
    it { is_expected.to have_db_column(:title).of_type(:text) }
    it { is_expected.to have_db_column(:journal).of_type(:string) }
    it { is_expected.to have_db_column(:volume).of_type(:string) }
    it { is_expected.to have_db_column(:edition).of_type(:string) }
    it { is_expected.to have_db_column(:pages).of_type(:string) }
    it { is_expected.to have_db_column(:date).of_type(:string) }
    it { is_expected.to have_db_column(:item).of_type(:string) }
    it { is_expected.to have_db_column(:booktitle).of_type(:string) }
    it { is_expected.to have_db_column(:container).of_type(:string) }
    it { is_expected.to have_db_column(:contype).of_type(:string) }
    it { is_expected.to have_db_column(:genre).of_type(:string) }
    it { is_expected.to have_db_column(:doi).of_type(:string) }
    it { is_expected.to have_db_column(:editor).of_type(:text) }
    it { is_expected.to have_db_column(:institution).of_type(:string) }
    it { is_expected.to have_db_column(:isbn).of_type(:string) }
    it { is_expected.to have_db_column(:location).of_type(:string) }
    it { is_expected.to have_db_column(:note).of_type(:string) }
    it { is_expected.to have_db_column(:publisher).of_type(:string) }
    it { is_expected.to have_db_column(:retrieved).of_type(:string) }
    it { is_expected.to have_db_column(:tech).of_type(:string) }
    it { is_expected.to have_db_column(:translator).of_type(:string) }
    it { is_expected.to have_db_column(:unknown).of_type(:string) }
    it { is_expected.to have_db_column(:url).of_type(:string) }
    it { is_expected.to have_db_column(:username).of_type(:string) }
    it { is_expected.to have_db_column(:citation).of_type(:text) }
    it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
    it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }

    it { is_expected.to have_db_index(:publication_listing_id) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:publication_listing) }
  end

  describe 'serializations' do
    it { is_expected.to serialize(:author) }
    it { is_expected.to serialize(:editor) }
  end
end

