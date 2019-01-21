module RemoteTranslationsHelper

  def display_remote_translation_info?(remote_translations, locale)
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

  def display_remote_translation_button?(remote_translations)
    display_button = false
    remote_translations.each do |remote_translation|
       display_button = true unless remote_translation_enqueued?(remote_translation)
    end
    display_button
  end

  def remote_translation_enqueued?(remote_translation)
    RemoteTranslation.where(remote_translatable_id: remote_translation[:remote_translatable_id],
                            remote_translatable_type: remote_translation[:remote_translatable_type],
                            locale: remote_translation[:locale],
                            error_message: nil).any?
  end

end
