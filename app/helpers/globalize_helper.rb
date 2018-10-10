module GlobalizeHelper

  def options_for_locale_select
    options_for_select(locale_options, nil)
  end

  def locale_options
    I18n.available_locales.map do |locale|
      [name_for_locale(locale), locale]
    end
  end

  def display_translation?(locale)
    locale == I18n.locale
  end

  def display_translation_style(locale)
    "display: none;" unless display_translation?(locale)
  end

  def translation_enabled_tag(locale, enabled)
    hidden_field_tag("enabled_translations[#{locale}]", (enabled ? 1 : 0))
  end

  def enable_translation_style(resource, locale)
    "display: none;" unless enable_locale?(resource, locale)
  end

  def enable_locale?(resource, locale)
    # Use `map` instead of `pluck` in order to keep the `params` sent
    # by the browser when there's invalid data
    resource.translations.reject(&:_destroy).map(&:locale).include?(locale) || locale == I18n.locale
  end

  def highlight_class(locale)
    "is-active" if display_translation?(locale)
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
