module Translatable
  extend ActiveSupport::Concern

  included do
    before_action :delete_translations, only: [:update]
  end

  private

    def translation_params(resource_model)
      return [] unless params[:enabled_translations]

      resource_model.translated_attribute_names.product(enabled_translations).map do |attr_name, loc|
        resource_model.localized_attr_name_for(attr_name, loc)
      end
    end

    def delete_translations
      locales = resource.translated_locales
                        .select { |l| params.dig(:enabled_translations, l) == "0" }

      locales.each do |l|
        Globalize.with_locale(l) do
          resource.translation.destroy
        end
      end
    end

    def enabled_translations
      params.fetch(:enabled_translations)
            .select { |_, v| v == '1' }
            .keys
    end
end
