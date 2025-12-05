require "rails_helper"

RSpec.describe Committee, type: :model do
  it { is_expected.to belong_to(:faculty) }
end
