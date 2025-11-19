class LocalCensusRecord < ApplicationRecord
  normalizes :document_type, :document_number, :postal_code, with: ->(value) { value.strip }

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
end
