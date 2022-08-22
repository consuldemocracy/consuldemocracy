class Layout::LocaleSwitcherComponent < ApplicationComponent
  delegate :name_for_locale, :link_list, :current_path_with_query_params, :rtl?, to: :helpers

  def render?
    locales.size > 1
  end

  private

    def many_locales?
      locales.size > 4
    end

    def locales
      I18n.available_locales
    end

    def label
      t("layouts.header.locale")
    end

    def label_id
      "locale_switcher_label"
    end

    def language_links
      locales.map do |locale|
        [
          name_for_locale(locale),
          current_path_with_query_params(locale: locale),
          locale == I18n.locale,
          lang: locale,
          data: { turbolinks: rtl?(I18n.locale) == rtl?(locale) }
        ]
      end
    end

    def language_options
      language_links.map do |text, path, _, options|
        [text, path, options]
      end
    end
end
