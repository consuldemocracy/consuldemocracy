class Admin::SiteCustomization::InformationTexts::FormFieldComponent < ApplicationComponent
  attr_reader :i18n_content, :locale
  delegate :globalize, :site_customization_display_translation_style, to: :helpers

  def initialize(i18n_content, locale:)
    @i18n_content = i18n_content
    @locale = locale
  end

  private

    def text
      if i18n_content.present?
        I18nContentTranslation.find_by(i18n_content_id: i18n_content.id, locale: locale)&.value
      else
        false
      end
    end
end
