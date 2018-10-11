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
            @template.content_tag :div, translations_options(translations_form.object, locale) do
              @template.concat translations_form.hidden_field(
                :_destroy,
                class: "destroy_locale",
                data: { locale: locale })

              @template.concat translations_form.hidden_field(:locale, value: locale)

              yield translations_form
            end
          end
        end
      end.join.html_safe
    end

    private

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

      def translations_options(resource, locale)
        {
          class: "translatable_fields js-globalize-attribute",
          style: @template.display_translation_style(resource.globalized_model, locale),
          data:  { locale: locale }
        }
      end
  end

  class TranslationsFieldsBuilder < FoundationRailsHelper::FormBuilder
    %i[text_field text_area cktext_area].each do |field|
      define_method field do |attribute, options = {}|
        custom_label(attribute, options[:label], options[:label_options]) +
          help_text(options[:hint]) +
          super(attribute, options.merge(label: false, hint: false))
      end
    end

    def locale
      @object.locale
    end

    def label(attribute, text = nil, options = {})
      label_options = options.dup
      hint = label_options.delete(:hint)

      super(attribute, text, label_options) + help_text(hint)
    end

    private
      def help_text(text)
        if text
          content_tag :span, text, class: "help-text"
        end
      end
  end
end
