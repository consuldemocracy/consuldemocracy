class TranslatableFormBuilder < ConsulFormBuilder
  attr_accessor :translations

  def translatable_fields(&)
    @translations = {}
    visible_locales.map do |locale|
      @translations[locale] = translation_for(locale)
    end
    safe_join(visible_locales.map do |locale|
      Globalize.with_locale(locale) { fields_for_locale(locale, &) }
    end)
  end

  private

    def fields_for_locale(locale)
      fields_for_translation(@translations[locale]) do |translations_form|
        @template.tag.div(**translations_options(translations_form.object, locale)) do
          @template.concat translations_form.hidden_field(
            :_destroy,
            value: !@template.enabled_locale?(translations_form.object.globalized_model, locale),
            data: { locale: locale }
          )

          @template.concat translations_form.hidden_field(:locale, value: locale)

          yield translations_form
        end
      end
    end

    def fields_for_translation(translation, &)
      fields_for(:translations, translation, builder: TranslationsFieldsFormBuilder, &)
    end

    def translation_for(locale)
      existing_translation_for(locale) || new_translation_for(locale)
    end

    def existing_translation_for(locale)
      @object.translations.find { |translation| translation.locale == locale }
    end

    def new_translation_for(locale)
      @object.translations.new(locale: locale).tap(&:mark_for_destruction)
    end

    def highlight_translation_html_class
      @template.highlight_translation_html_class
    end

    def translations_options(resource, locale)
      {
        class: "translatable-fields js-globalize-attribute #{highlight_translation_html_class}",
        style: @template.display_translation_style(resource.globalized_model, locale),
        data: { locale: locale }
      }
    end

    def no_other_translations?(translation)
      (@object.translations - [translation]).reject(&:_destroy).empty?
    end

    def visible_locales
      if @template.translations_interface_enabled?
        Setting.enabled_locales & @object.globalize_locales
      else
        [I18n.locale]
      end
    end
end
