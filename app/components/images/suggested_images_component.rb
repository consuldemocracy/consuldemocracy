class Images::SuggestedImagesComponent < ApplicationComponent
  attr_reader :resource_type, :resource_id, :resource_attributes

  def initialize(resource_type:, resource_id: nil, resource_attributes: {})
    @resource_type = resource_type
    @resource_id = resource_id
    @resource_attributes = resource_attributes
  end

  def suggested_images
    return [] if model_instance.blank?

    results = response.results
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
      @model_instance ||= resource_type.safe_constantize&.new(attributes_without_ids)
    end

    def attributes_without_ids(attrs = resource_attributes)
      attrs = attrs.to_unsafe_h if attrs.respond_to?(:to_unsafe_h)

      case attrs
      when Hash
        attrs.each_with_object({}) do |(key, value), result|
          next if key.to_s == "id"

          result[key] = attributes_without_ids(value)
        end
      when Array
        attrs.map { |item| attributes_without_ids(item) }
      else
        attrs
      end
    end
end
