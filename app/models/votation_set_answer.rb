class VotationSetAnswer < ApplicationRecord
  belongs_to :votation_type
  belongs_to :author, ->   { with_hidden }, class_name: "User", foreign_key: "author_id"

  scope :by_author, -> (author) { where(author: author) }
end
