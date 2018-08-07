class Work < ApplicationRecord
  serialize :author
  serialize :editor
  belongs_to :publication_listing
end
