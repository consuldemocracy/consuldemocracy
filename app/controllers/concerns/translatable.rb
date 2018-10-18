module Translatable
  extend ActiveSupport::Concern

  private

    def translation_params(resource_model)
      {
        translations_attributes: [:id, :_destroy, :locale] +
                                 resource_model.translated_attribute_names
      }
    end
end
