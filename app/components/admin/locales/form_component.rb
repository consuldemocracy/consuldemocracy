class Admin::Locales::FormComponent < ApplicationComponent
  attr_reader :enabled_locales, :default
  use_helpers :name_for_locale

  def initialize(enabled_locales, default:)
    @enabled_locales = enabled_locales
    @default = default
  end

  private

    def available_locales
      I18n.available_locales
    end

    def many_available_locales?
      available_locales.count > select_field_threshold
    end

    def locales_options
      options_for_select(
        available_locales.map { |locale| [name_for_locale(locale), locale] },
        default
      )
    end

    def select_field_threshold
      10
    end
end
