class LocalCensusRecord < ApplicationRecord
  before_validation :sanitize

  validates :document_number, presence: true
  validates :document_type, presence: true
  validates :document_type, inclusion: { in: ["1", "2", "3"], allow_blank: true }
  validates :date_of_birth, presence: true
  validates :postal_code, presence: true
  validates :document_number, uniqueness: { scope: :document_type }

  scope :search, ->(terms) { where("document_number ILIKE ?", "%#{terms}%") }

  def title
    "#{ApplicationController.helpers.humanize_document_type(document_type)} #{document_number}"
  end

  private

    def sanitize
      self.document_type   = document_type&.strip
      self.document_number = document_number&.strip
      self.postal_code     = postal_code&.strip
    end
end
