module RemoteTranslationsHelper

  def display_remote_translation_button?(remote_translations, locale)
    available_remote_locales = RemoteTranslationsCaller.new.available_remote_locales
    remote_translations.present? && available_remote_locales.include?(parse_locale(locale))
  end

  def parse_locale(locale)
    case locale
    when :"pt-BR"
      "pt"
    when :"zh-CN"
      "zh-Hans"
    when :"zh-TW"
      "zh-Hant"
    else
      locale.to_s
    end
  end

end
