module GlobalizeHelper

  def options_for_select_language(resource)
    options_for_select(available_locales(resource), first_available_locale(resource))
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

  def languages_count
    count = I18nContentTranslation.existing_languages.count
    count > 0 ? count : 1
  end

  def display_translation_style(resource, locale)
    "display: none;" unless display_translation?(resource, locale)
  end

  def display_translation?(resource, locale)
    if !resource || resource.translations.empty? ||
       resource.locales_not_marked_for_destruction.include?(I18n.locale)
      locale == I18n.locale
    else
      locale == resource.translations.first.locale
    end
  end

  def display_destroy_locale_style(resource, locale)
    "display: none;" unless display_destroy_locale_link?(resource, locale)
  end

  def display_destroy_locale_link?(resource, locale)
    first_available_locale(resource) == locale
  end

  def options_for_add_language
    options_for_select(all_language_options, nil)
  end

  def all_language_options
    I18n.available_locales.map do |locale|
      [name_for_locale(locale), locale]
    end
  end

  def can_manipulate_languages?
    params[:controller] != "admin/legislation/milestones" &&
      params[:controller] != "admin/legislation/homepages"
  end

  def translation_enabled_tag(locale, enabled)
    hidden_field_tag("enabled_translations[#{locale}]", (enabled ? 1 : 0))
  end

  def globalize(locale, &block)
    Globalize.with_locale(locale) do
      yield
    end
  end
end
