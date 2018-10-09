module TranslatableFormHelper
  def translatable_form_for(record, options = {})
    form_for(record, options.merge(builder: TranslatableFormBuilder)) do |f|
      yield(f)
    end
  end

  def merge_translatable_field_options(options, locale)
    options.merge(
      class: "#{options[:class]} js-globalize-attribute".strip,
      style: "#{options[:style]} #{display_translation?(locale)}".strip,
      data:  options.fetch(:data, {}).merge(locale: locale),
    )
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

        custom_label(attribute, final_options[:label], final_options[:label_options]) +
          help_text(final_options[:hint]) +
          super(attribute, final_options.merge(label: false, hint: false))
      end
    end

    def locale
      @object.locale
    end

    def label(attribute, text = nil, options = {})
      label_options = options.merge(
        class: "#{options[:class]} js-globalize-attribute".strip,
        style: "#{options[:style]} #{@template.display_translation?(locale)}".strip,
        data:  (options[:data] || {}) .merge(locale: locale)
      )

      hint = label_options.delete(:hint)
      super(attribute, text, label_options) + help_text(hint)
    end

    private
      def help_text(text)
        if text
          content_tag :span, text,
                      class: "help-text js-globalize-attribute",
                      data: { locale: locale },
                      style: @template.display_translation?(locale)
        else
          ""
        end
      end

      def translations_options(options)
        @template.merge_translatable_field_options(options, locale)
      end
  end
end
