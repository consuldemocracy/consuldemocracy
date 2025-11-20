module RemoteTranslations
  module Llm
    class AvailableLocales
      def self.locales
        I18n.available_locales.map(&:to_s)
      end
    end
  end
end
