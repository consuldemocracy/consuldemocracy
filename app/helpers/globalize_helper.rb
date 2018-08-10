module GlobalizeHelper

  def options_for_locale_select
    options_for_select(locale_options, nil)
  end

  def locale_options
    I18n.available_locales.map do |locale|
      [name_for_locale(locale), neutral_locale(locale)]
    end
  end

  def display_translation?(locale)
    same_locale?(neutral_locale(I18n.locale), neutral_locale(locale)) ? "" : "display: none"
  end

  def translation_enabled_tag(locale, enabled)
    hidden_field_tag("enabled_translations[#{locale}]", (enabled ? 1 : 0))
  end

  def css_to_display_translation?(resource, locale)
    enable_locale?(resource, locale) ? "" : "display: none"
  end

  def enable_locale?(resource, locale)
    resource.translated_locales.include?(neutral_locale(locale)) || locale == I18n.locale
  end

  def highlight_current?(locale)
    same_locale?(I18n.locale, locale) ? 'is-active' : ''
  end

  def show_delete?(locale)
    display_translation?(locale)
  end

  def neutral_locale(locale)
    locale.to_s.downcase.underscore.to_sym
  end

  def globalize(locale, &block)
    Globalize.with_locale(locale) do
      yield
    end
  end

  def same_locale?(locale1, locale2)
    locale1 == locale2
  end

end
