module Translatable
  extend ActiveSupport::Concern

  included do
    before_action :delete_translations, only: [:update]
  end

  private

    def translation_params(params)
      resource_model
        .globalize_attribute_names
        .select { |k| params[k].present? ||
                      resource_model.translated_locales.include?(get_locale_from_attribute(k)) }
    end

    def delete_translations
      locales = resource_model.translated_locales
                              .select { |l| params.dig(:delete_translations, l) == "1" }
      locales.each do |l|
        Globalize.with_locale(l) do
          resource.translation.destroy
        end
      end
    end

    def get_locale_from_attribute(attribute_name)
      locales = resource_model.globalize_locales
      attribute_name.to_s.match(/(#{locales.join('|')})\Z/)&.captures&.first
    end
end
