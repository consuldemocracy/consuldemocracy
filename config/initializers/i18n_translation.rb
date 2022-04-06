require "i18n/exceptions"
require "action_view/helpers/tag_helper"

module ActionView
  module Helpers
    module TranslationHelper
      include TagHelper

      def t(key, options = {})
        current_locale = options[:locale].presence || I18n.locale

        @i18n_content_translations ||= {}
        @i18n_content_translations[current_locale] ||= I18nContent.translations_hash(current_locale)

        translation = @i18n_content_translations[current_locale][key]

        if translation.present?
          translation % options
        else
          translate(key, options)
        end
      end
    end
  end
end
