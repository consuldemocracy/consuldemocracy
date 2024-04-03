class Shared::GlobalizeLocalesComponent < ApplicationComponent
  attr_reader :resource, :manage_languages
  use_helpers :first_translation, :first_marked_for_destruction_translation,
              :enabled_locale?, :name_for_locale, :highlight_translation_html_class

  def initialize(resource = nil, manage_languages: true)
    @resource = resource
    @manage_languages = manage_languages
  end

  private

    def options_for_select_language
      options_for_select(available_locales, selected_locale)
    end

    def available_locales
      I18n.available_locales.select { |locale| enabled_locale?(resource, locale) }.map do |locale|
        [name_for_locale(locale), locale, { data: { locale: locale }}]
      end
    end

    def selected_locale
      return first_i18n_content_translation_locale if resource.blank?

      if resource.locales_not_marked_for_destruction.any?
        first_translation(resource)
      elsif resource.locales_persisted_and_marked_for_destruction.any?
        first_marked_for_destruction_translation(resource)
      else
        I18n.locale
      end
    end

    def first_i18n_content_translation_locale
      if I18nContentTranslation.existing_languages.count == 0 ||
         I18nContentTranslation.existing_languages.include?(I18n.locale)
        I18n.locale
      else
        I18nContentTranslation.existing_languages.first
      end
    end

    def selected_languages_description
      sanitize(t("shared.translations.languages_in_use", count: active_languages_count))
    end

    def select_language_error
      return if resource.blank?

      current_translation = resource.translation_for(selected_locale)
      if current_translation.errors.added? :base, :translations_too_short
        tag.div class: "small error" do
          current_translation.errors[:base].join(", ")
        end
      end
    end

    def active_languages_count
      if resource.blank?
        no_resource_languages_count
      elsif resource.locales_not_marked_for_destruction.size > 0
        resource.locales_not_marked_for_destruction.size
      else
        1
      end
    end

    def no_resource_languages_count
      count = I18nContentTranslation.existing_languages.count
      count > 0 ? count : 1
    end

    def display_destroy_locale_style(locale)
      "display: none;" unless display_destroy_locale_link?(locale)
    end

    def display_destroy_locale_link?(locale)
      selected_locale == locale
    end

    def options_for_add_language
      options_for_select(all_language_options, nil)
    end

    def all_language_options
      I18n.available_locales.map do |locale|
        [name_for_locale(locale), locale]
      end
    end
end
