class Admin::SiteCustomization::InformationTexts::FormComponent < ApplicationComponent
  attr_reader :contents
  use_helpers :site_customization_enable_translation?

  def initialize(contents)
    @contents = contents
  end

  private

    def translation_enabled_tag(locale, enabled)
      hidden_field_tag("enabled_translations[#{locale}]", (enabled ? 1 : 0))
    end

    def enabled_locales
      Setting.enabled_locales
    end
end
