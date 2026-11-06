module NormalizesDocumentNumber
  extend ActiveSupport::Concern

  included do
    normalizes :document_number, with: ->(document_number) { document_number.gsub(/[^a-z0-9]+/i, "").upcase }
  end
end
