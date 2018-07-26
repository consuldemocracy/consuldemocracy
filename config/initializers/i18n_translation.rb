require 'i18n/exceptions'
require 'action_view/helpers/tag_helper'

module ActionView
  module Helpers
    module TranslationHelper
      include TagHelper

      def t(key, options = {})
        translation = I18nContent.by_key(key)

        if translation.present?
          Globalize.with_locale(locale) do
            string = translation.first.value

            options.each do |key, value|
              string.sub! "%{#{key}}", (value || "%{#{key}}")
            end

            return string.html_safe unless string.nil?
          end
        end

        translate(key, options)
      end
    end
  end
end
