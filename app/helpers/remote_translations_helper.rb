include RemoteAvailableLocales
module RemoteTranslationsHelper

  def display_remote_translation_info?(remote_translations, locale)
    available_remote_locales = RemoteTranslationsCaller.new.available_remote_locales
    remote_translations.present? && available_remote_locales.include?(parse_locale(locale).to_s)
  end

  def display_remote_translation_button?(remote_translations)
    remote_translations.none? do |remote_translation|
      RemoteTranslation.remote_translation_enqueued?(remote_translation)
    end
  end
end
