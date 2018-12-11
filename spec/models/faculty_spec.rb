require 'rails_helper'

describe Faculty, type: :model do
  describe 'associations' do
    it { is_expected.to have_one(:personal_contact) }
  end
end
