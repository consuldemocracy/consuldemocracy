module TranslatableFormHelper
  def translatable_form_for(record, options = {})
    form_for(record, options.merge(builder: TranslatableFormBuilder)) do |f|
      yield(f)
    end
  end

  class TranslatableFormBuilder < FoundationRailsHelper::FormBuilder
    def translatable_fields(&block)
      @object.globalize_locales.map do |locale|
        Globalize.with_locale(locale) { fields_for_locale(locale, &block) }
      end.join.html_safe
    end

    private

      def fields_for_locale(locale, &block)
        fields_for_translation(translation_for(locale)) do |translations_form|
          @template.content_tag :div, translations_options(translations_form.object, locale) do
            @template.concat translations_form.hidden_field(
              :_destroy,
              data: { locale: locale }
            )

            @template.concat translations_form.hidden_field(:locale, value: locale)

            yield translations_form
          end
        end
      end

      def fields_for_translation(translation, &block)
        fields_for(:translations, translation, builder: TranslationsFieldsBuilder) do |f|
          yield f
        end
      end

      def translation_for(locale)
        existing_translation_for(locale) || new_translation_for(locale)
      end

      def existing_translation_for(locale)
        @object.translations.detect { |translation| translation.locale == locale }
      end

      def new_translation_for(locale)
        @object.translations.new(locale: locale).tap do |translation|
          unless locale == I18n.locale && no_other_translations?(translation)
            translation.mark_for_destruction
          end
        end
      end

      def translations_options(resource, locale)
        {
          class: "translatable-fields js-globalize-attribute",
          style: @template.display_translation_style(resource.globalized_model, locale),
          data:  { locale: locale }
        }
      end

      def no_other_translations?(translation)
        (@object.translations - [translation]).reject(&:_destroy).empty?
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
