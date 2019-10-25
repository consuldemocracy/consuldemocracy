class VotationSetAnswer < ApplicationRecord
  belongs_to :votation_type
  belongs_to :author, -> { with_hidden }, class_name: "User", inverse_of: :votation_set_answers

  scope :by_author, -> (author) { where(author: author) }
end
