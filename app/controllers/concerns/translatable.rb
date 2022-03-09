module Translatable
  extend ActiveSupport::Concern

  private

    def translation_params(resource_model, options = {})
      attributes = [:id, :locale, :_destroy]
      if options[:only]
        attributes += Array(options[:only])
      else
        attributes += resource_model.translated_attribute_names
      end
      { translations_attributes: attributes - Array(options[:except]) }
    end
end
