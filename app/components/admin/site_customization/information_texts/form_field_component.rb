class Admin::SiteCustomization::InformationTexts::FormFieldComponent < ApplicationComponent
  attr_reader :i18n_content, :locale
  delegate :globalize, :site_customization_display_translation_style, to: :helpers

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
      I18n.translate(i18n_content.key, locale: locale)
    end
end
