module SiteCustomizationHelper
  def site_customization_display_translation?(locale)
    I18nContentTranslation.existing_languages.include?(neutral_locale(locale)) ? "" : "display: none"
  end
end
