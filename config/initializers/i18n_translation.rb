require 'i18n/exceptions'
require 'action_view/helpers/tag_helper'

module ActionView
  module Helpers
    module TranslationHelper
      include TagHelper

      def t(key, options = {})
        if translation = I18nContent.by_key(key).last
          Globalize.with_locale(locale) do
            string = I18nContent.where(key: key).first.value
            options.each do |key, value|
              string.sub! "%{#{key}}", (value || "%{#{key}}")
            end
            return string.html_safe
          end
        end
        translate(key, options)
      end
    end
  end
end
