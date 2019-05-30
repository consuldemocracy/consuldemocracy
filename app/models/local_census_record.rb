class LocalCensusRecord < ApplicationRecord
  before_validation :sanitize

  validates :document_number, presence: true
  validates :document_type, presence: true
  validates :date_of_birth, presence: true
  validates :postal_code, presence: true
  validates :document_number, uniqueness: { scope: :document_type }

  scope :search,  -> (terms) { where("document_number ILIKE ?", "%#{terms}%") }

  private

    def sanitize
      self.document_type   = self.document_type&.strip
      self.document_number = self.document_number&.strip
      self.postal_code     = self.postal_code&.strip
    end
end
