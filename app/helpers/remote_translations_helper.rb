module RemoteTranslationsHelper

  def display_remote_translation_info?(remote_translations, locale)
    remote_translations.present? && RemoteTranslations::Microsoft::AvailableLocales.include_locale?(locale)
  end
end
