module SiteCustomizationHelper
  def site_customization_enable_translation?(locale)
    I18nContentTranslation.existing_languages.include?(locale) || locale == I18n.locale
  end

  def site_customization_display_translation?(locale)
    site_customization_enable_translation?(locale) ? "" : "display: none;"
  end
end
