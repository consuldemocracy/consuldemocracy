module GlobalizeHelper
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

  def globalize(locale, &)
    Globalize.with_locale(locale, &)
  end
end
