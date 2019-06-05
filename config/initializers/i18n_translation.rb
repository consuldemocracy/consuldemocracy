require 'i18n/exceptions'
require 'action_view/helpers/tag_helper'

module ActionView
  module Helpers
    module TranslationHelper
      include TagHelper

      def t(key, options = {})
        current_locale = options[:locale].present? ? options[:locale] : I18n.locale

        i18_content = I18nContent.by_key(key).first
        translation = I18nContentTranslation.where(i18n_content_id: i18_content&.id,
                                                   locale: current_locale).first&.value
        if translation.present?
          translation
        else
          translate(key, options)
        end
      end
    end
  end
end
