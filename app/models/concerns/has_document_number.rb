module HasDocumentNumber
  extend ActiveSupport::Concern

  included do
    attribute :document_number, :string
    normalizes :document_number, with: DocumentNumberNormalizer
  end
end
