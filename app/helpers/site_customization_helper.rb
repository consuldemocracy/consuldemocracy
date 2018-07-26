module SiteCustomizationHelper
  def site_customization_display_translation?(locale)
    I18nContentTranslation.existing_languages.include?(neutral_locale(locale)) || locale == I18n.locale ? "" : "display: none"
  end
end
