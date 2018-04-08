module Documentable
  extend ActiveSupport::Concern

  included do
    has_many :documents, as: :documentable, dependent: :destroy
    accepts_nested_attributes_for :documents, allow_destroy: true
  end

  module ClassMethods
    attr_reader :max_documents_allowed, :max_file_size, :accepted_content_types

    private

    def documentable(options = {})
      @max_documents_allowed = options[:max_documents_allowed]
      @max_file_size = options[:max_file_size]
      @accepted_content_types = options[:accepted_content_types]
    end

  end

end
