module GlobalizeHelper

  def options_for_locale_select
    options_for_select(locale_options, nil)
  end

  def available_locales(resource)
    I18n.available_locales.select{ |locale| enabled_locale?(resource, locale) }.map do |locale|
      [name_for_locale(locale), locale , { data: { locale: locale } }]
    end
  end

  def enabled_locale?(resource, locale)
    return site_customization_enable_translation?(locale) if resource.blank?

    if resource.translations.empty?
      locale == I18n.locale
    else
      resource.locales_not_marked_for_destruction.include?(locale)
    end
  end

  def first_available_locale(resource)
    return first_i18n_content_translation_locale if resource.blank?

    if translations_for_locale?(resource, I18n.locale)
      I18n.locale
    elsif resource.translations.any?
      resource.translations.first.locale
    else
      I18n.locale
    end
  end

  def first_i18n_content_translation_locale
    if I18nContentTranslation.existing_languages.count == 0 ||
        I18nContentTranslation.existing_languages.include?(I18n.locale)
      I18n.locale
    else
      I18nContentTranslation.existing_languages.first
    end
  end

  def translations_for_locale?(resource, locale)
    resource.present? && resource.translations.any? &&
      resource.locales_not_marked_for_destruction.include?(locale)
  end

  def selected_languages_description(resource)
    t("shared.translations.languages_in_use_html", count: active_languages_count(resource))
  end

  def active_languages_count(resource)
    if resource.blank?
      languages_count
    elsif resource.locales_not_marked_for_destruction.size > 0
      resource.locales_not_marked_for_destruction.size
    else
      1
    end
  end

  def display_translation?(resource, locale)
    if !resource || resource.translations.blank? ||
       resource.locales_not_marked_for_destruction.include?(I18n.locale)
      locale == I18n.locale
    else
      locale == resource.translations.first.locale
    end
  end

  def display_translation_style(resource, locale)
    "display: none;" unless display_translation?(resource, locale)
  end

  def translation_enabled_tag(locale, enabled)
    hidden_field_tag("enabled_translations[#{locale}]", (enabled ? 1 : 0))
  end

  def enable_translation_style(resource, locale)
    "display: none;" unless enable_locale?(resource, locale)
  end

  def enable_locale?(resource, locale)
    if resource.translations.any?
      resource.locales_not_marked_for_destruction.include?(locale)
    else
      locale == I18n.locale
    end
  end

  def highlight_class(resource, locale)
    "is-active" if display_translation?(resource, locale)
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
