module TranslatableFormHelper
  def translatable_form_for(record, options = {})
    form_for(record, options.merge(builder: TranslatableFormBuilder)) do |f|
      yield(f)
    end
  end

  class TranslatableFormBuilder < FoundationRailsHelper::FormBuilder
    def translatable_fields(&block)
      @object.globalize_locales.map do |locale|
        Globalize.with_locale(locale) do
          fields_for(:translations, translation_for(locale), builder: TranslationsFieldsBuilder) do |translations_form|
            @template.concat translations_form.hidden_field(
              :_destroy,
              class: "destroy_locale",
              data: { locale: locale })

            @template.concat translations_form.hidden_field(:locale, value: locale)

            yield translations_form
          end
        end
      end.join.html_safe
    end

    def translation_for(locale)
      existing_translation_for(locale) || new_translation_for(locale)
    end

    def existing_translation_for(locale)
      # Use `select` because `where` uses the database and so ignores
      # the `params` sent by the browser
      @object.translations.select { |translation| translation.locale == locale }.first
    end

    def new_translation_for(locale)
      @object.translations.new(locale: locale).tap do |translation|
        translation.mark_for_destruction unless locale == I18n.locale
      end
    end
  end

  class TranslationsFieldsBuilder < FoundationRailsHelper::FormBuilder
    %i[text_field text_area cktext_area].each do |field|
      define_method field do |attribute, options = {}|
        final_options = translations_options(options)

        label_help_text_and_field =
          custom_label(attribute, final_options[:label], final_options[:label_options]) +
          help_text(final_options[:hint]) +
          super(attribute, final_options.merge(label: false, hint: false))

        if field == :cktext_area
          content_tag :div,
                      label_help_text_and_field,
                      class: "js-globalize-attribute",
                      style: display_style,
                      data: { locale: locale }
        else
          label_help_text_and_field
        end
      end
    end

    def locale
      @object.locale
    end

    def label(attribute, text = nil, options = {})
      label_options = translations_options(options)
      hint = label_options.delete(:hint)

      super(attribute, text, label_options) + help_text(hint)
    end

    def display_style
      @template.display_translation_style(@object.globalized_model, locale)
    end

    private
      def help_text(text)
        if text
          content_tag :span, text,
                      class: "help-text js-globalize-attribute",
                      data: { locale: locale },
                      style: display_style
        else
          ""
        end
      end

      def translations_options(options)
        options.merge(
          class: "#{options[:class]} js-globalize-attribute".strip,
          style: "#{options[:style]} #{display_style}".strip,
          data:  (options[:data] || {}).merge(locale: locale)
        )
      end
  end
end
