module HasDocumentNumberAndDocumentType
  extend ActiveSupport::Concern
  include HasDocumentNumber

  included do
    attribute :document_type, :string
    normalizes :document_type, with: ->(document_type) { document_type.strip }
  end
end
