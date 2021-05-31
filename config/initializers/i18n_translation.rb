require "i18n/exceptions"
require "action_view/helpers/tag_helper"

module ActionView
  module Helpers
    module TranslationHelper
      include TagHelper

      def t(key, options = {})
        current_locale = options[:locale].presence || I18n.locale

        i18_content = I18nContent.find_by(key: key)
        translation = I18nContentTranslation.find_by(i18n_content_id: i18_content&.id,
                                                     locale: current_locale)&.value
        if translation.presence 
	 translation % options
	else
		translate(key, options)
      	end
      end
    end
  end
end
