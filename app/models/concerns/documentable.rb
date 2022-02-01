module Documentable
  extend ActiveSupport::Concern

  included do
    has_many :documents, as: :documentable, inverse_of: :documentable, dependent: :destroy
    accepts_nested_attributes_for :documents, allow_destroy: true
  end

  module ClassMethods
    def max_documents_allowed
      Setting["uploads.documents.max_amount"].to_i
    end

    def max_file_size
      Setting["uploads.documents.max_size"].to_i
    end

    def accepted_content_types
      Setting["uploads.documents.content_types"]&.split(" ") || ["application/pdf"]
    end
  end
end
