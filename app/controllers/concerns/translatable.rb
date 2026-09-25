module Translatable
  extend ActiveSupport::Concern

  private

    def translation_params(resource_model, options = {})
      base_attributes = [:id, :locale, :_destroy]

      attributes = if options[:only]
                     Array(options[:only])
                   else
                     resource_model.translated_attribute_names
                   end

      filtered_attributes = attributes - Array(options[:except])

      if request.format.json?
        [*filtered_attributes, { translations_attributes: base_attributes + filtered_attributes }]
      else
        [{ translations_attributes: base_attributes + filtered_attributes }]
      end
    end
end
