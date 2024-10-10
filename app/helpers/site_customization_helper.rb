module SiteCustomizationHelper
  def site_customization_enable_translation?(locale)
    I18nContentTranslation.existing_locales.include?(locale) || locale == I18n.locale
  end

  def information_texts_tabs
    [:basic, :debates, :community, :proposals, :polls, :legislation, :budgets, :layouts, :mailers,
     :management, :welcome, :machine_learning]
  end
end
