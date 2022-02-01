module GlobalizeHelper
  def options_for_select_language(resource)
    options_for_select(available_locales(resource), selected_locale(resource))
  end

  def available_locales(resource)
    I18n.available_locales.select { |locale| enabled_locale?(resource, locale) }.map do |locale|
      [name_for_locale(locale), locale, { data: { locale: locale }}]
    end
  end

  def enabled_locale?(resource, locale)
    return site_customization_enable_translation?(locale) if resource.blank?

    if resource.locales_not_marked_for_destruction.any?
      resource.locales_not_marked_for_destruction.include?(locale)
    elsif resource.locales_persisted_and_marked_for_destruction.any?
      locale == first_marked_for_destruction_translation(resource)
    else
      locale == I18n.locale
    end
  end

  def selected_locale(resource)
    return first_i18n_content_translation_locale if resource.blank?

    if resource.locales_not_marked_for_destruction.any?
      first_translation(resource)
    elsif resource.locales_persisted_and_marked_for_destruction.any?
      first_marked_for_destruction_translation(resource)
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

  def first_translation(resource)
    if resource.locales_not_marked_for_destruction.include? I18n.locale
      I18n.locale
    else
      resource.locales_not_marked_for_destruction.first
    end
  end

  def first_marked_for_destruction_translation(resource)
    if resource.locales_persisted_and_marked_for_destruction.include? I18n.locale
      I18n.locale
    else
      resource.locales_persisted_and_marked_for_destruction.first
    end
  end

  def translations_for_locale?(resource)
    resource.locales_not_marked_for_destruction.any?
  end

  def selected_languages_description(resource)
    sanitize(t("shared.translations.languages_in_use", count: active_languages_count(resource)))
  end

  def select_language_error(resource)
    return if resource.blank?

    current_translation = resource.translation_for(selected_locale(resource))
    if current_translation.errors.added? :base, :translations_too_short
      tag.div class: "small error" do
        current_translation.errors[:base].join(", ")
      end
    end
  end

  def active_languages_count(resource)
    if resource.blank?
      no_resource_languages_count
    elsif resource.locales_not_marked_for_destruction.size > 0
      resource.locales_not_marked_for_destruction.size
    else
      1
    end
  end

  def no_resource_languages_count
    count = I18nContentTranslation.existing_languages.count
    count > 0 ? count : 1
  end

  def display_translation_style(resource, locale)
    "display: none;" unless display_translation?(resource, locale)
  end

  def display_translation?(resource, locale)
    return locale == I18n.locale if resource.blank?

    if resource.locales_not_marked_for_destruction.any?
      locale == first_translation(resource)
    elsif resource.locales_persisted_and_marked_for_destruction.any?
      locale == first_marked_for_destruction_translation(resource)
    else
      locale == I18n.locale
    end
  end

  def display_destroy_locale_style(resource, locale)
    "display: none;" unless display_destroy_locale_link?(resource, locale)
  end

  def display_destroy_locale_link?(resource, locale)
    selected_locale(resource) == locale
  end

  def options_for_add_language
    options_for_select(all_language_options, nil)
  end

  def all_language_options
    I18n.available_locales.map do |locale|
      [name_for_locale(locale), locale]
    end
  end

  def translation_enabled_tag(locale, enabled)
    hidden_field_tag("enabled_translations[#{locale}]", (enabled ? 1 : 0))
  end

  def globalize(locale, &block)
    Globalize.with_locale(locale, &block)
  end
end
