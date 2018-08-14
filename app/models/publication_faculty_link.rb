class PublicationFacultyLink < ApplicationRecord
  belongs_to :faculty
  belongs_to :publication
end
