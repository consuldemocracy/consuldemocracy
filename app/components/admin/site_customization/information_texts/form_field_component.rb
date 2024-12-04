class Admin::SiteCustomization::InformationTexts::FormFieldComponent < ApplicationComponent
  attr_reader :i18n_content, :locale
  use_helpers :globalize, :site_customization_enable_translation?

  def initialize(i18n_content, locale:)
    @i18n_content = i18n_content
    @locale = locale
  end

  private

    def text
      database_text || i18n_text
    end

    def database_text
      if i18n_content.persisted?
        i18n_content.translations.find_by(locale: locale)&.value
      end
    end

    def i18n_text
      I18n.translate(i18n_key, locale: locale)
    end

    def i18n_key
      i18n_content.key
    end

    def html_id
      html_name.tr("[", "_").tr("]", "")
    end

    def html_name
      "contents[content_#{i18n_key}]values[value_#{locale}]"
    end

    def display_style
      site_customization_enable_translation?(locale) ? "" : "display: none;"
    end
end
