module SiteCustomizationHelper
  def site_customization_enable_translation?(locale)
    I18nContentTranslation.existing_languages.include?(locale) || locale == I18n.locale
  end

  def site_customization_display_translation_style(locale)
    site_customization_enable_translation?(locale) ? "" : "display: none;"
  end

  def translation_for_locale(content, locale)
    i18n_content = I18nContent.where(key: content.key).first

    if i18n_content.present?
      I18nContentTranslation.where(
        i18n_content_id: i18n_content.id,
        locale: locale
      ).first.try(:value)
    else
      false
    end
  end
end
