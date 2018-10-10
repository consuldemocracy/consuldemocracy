module SiteCustomizationHelper
  def site_customization_enable_translation?(locale)
    I18nContentTranslation.existing_languages.include?(locale) || locale == I18n.locale
  end

  def site_customization_display_translation_style(locale)
    site_customization_enable_translation?(locale) ? "" : "display: none;"
  end

  def merge_translatable_field_options(options, locale)
    options.merge(
      class: "#{options[:class]} js-globalize-attribute".strip,
      style: "#{options[:style]} #{site_customization_display_translation_style(locale)}".strip,
      data:  (options[:data] || {}).merge(locale: locale)
    )
  end
end
