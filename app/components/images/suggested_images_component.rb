module Images
  class SuggestedImagesComponent < ApplicationComponent
    attr_reader :resource_type, :resource_id, :resource_attributes

    def initialize(resource_type:, resource_id: nil, resource_attributes: {})
      @resource_type = resource_type
      @resource_id = resource_id
      @resource_attributes = resource_attributes
    end

    def suggested_images
      results = response&.results
      return [] if results.blank?

      results.photos
    end

    def has_errors?
      response.errors.any?
    end

    def error_messages
      response.errors
    end

    private

      def response
        @response ||= ImageSuggestions::Llm::Client.call(model_instance)
      end

      def model_instance
        @model_instance ||= resource_type.constantize.new(resource_attributes)
      end
  end
end
