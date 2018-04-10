module GlobalizeHelper

  def globalize_locale
    params[:globalize_locale] || I18n.locale
  end

  def options_for_locale_select
    options_for_select(locale_options, nil)
  end

  def locale_options
    I18n.available_locales.map do |locale|
      [name_for_locale(locale), locale]
    end
  end

  def display_translation?(locale)
    I18n.locale == locale ? "" : "display: none"
  end

  def css_to_display_translation?(resource, locale)
    resource.translated_locales.include?(locale) || locale == I18n.locale ? "" : "display: none"
  end

  def disable_translation?(locale)
    locale == "en" ? "" : "disabled"
  end

  def css_for_globalize_locale(locale)
    globalize_locale == locale ? "highlight" : ""
  end

end