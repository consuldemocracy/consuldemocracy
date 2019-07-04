module Globalize
  module ActiveRecord
    module InstanceMethods
      def save(*)
        # Credit for this code belongs to Jack Tomaszewski:
        # https://github.com/globalize/globalize/pull/578
        Globalize.with_locale(Globalize.locale || I18n.default_locale) do
          super
        end
      end
    end
  end
end

def Globalize.set_fallbacks_to_all_available_locales
  Globalize.fallbacks = I18n.available_locales.each_with_object({}) do |locale, fallbacks|
    fallbacks[locale] = (I18n.fallbacks[locale] + I18n.available_locales).uniq
  end
end
