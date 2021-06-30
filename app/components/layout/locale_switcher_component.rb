class Layout::LocaleSwitcherComponent < ApplicationComponent
  delegate :name_for_locale, :current_path_with_query_params, to: :helpers

  def render?
    locales.size > 1
  end

  private

    def locales
      I18n.available_locales
    end

    def language_options
      locales.map do |locale|
        [name_for_locale(locale), current_path_with_query_params(locale: locale), lang: locale]
      end
    end
end
