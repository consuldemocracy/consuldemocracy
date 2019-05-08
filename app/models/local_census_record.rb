class LocalCensusRecord < ApplicationRecord
  validates :document_number, presence: true
  validates :document_type, presence: true
  validates :date_of_birth, presence: true
  validates :postal_code, presence: true

  scope :search,  -> (terms) { where("document_number ILIKE ?", "%#{terms}%") }
end
