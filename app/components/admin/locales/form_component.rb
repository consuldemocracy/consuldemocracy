class Admin::Locales::FormComponent < ApplicationComponent
  attr_reader :locales_settings
  use_helpers :name_for_locale

  def initialize(locales_settings)
    @locales_settings = locales_settings
  end

  private

    def available_locales
      I18n.available_locales
    end

    def many_available_locales?
      available_locales.count > select_field_threshold
    end

    def locales_options
      available_locales.map { |locale| [name_for_locale(locale), locale] }
    end

    def select_field_threshold
      10
    end

    def attribute_name(...)
      locales_settings.class.human_attribute_name(...)
    end
end
