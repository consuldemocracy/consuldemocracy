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
      label_options: {
        class: "#{options.dig(:label_options, :class)} js-globalize-attribute".strip,
        style: "#{options.dig(:label_options, :style)} #{display_translation?(locale)}".strip,
        data:  (options.dig(:label_options, :data) || {}) .merge(locale: locale)
      }
    )
  end

  class TranslatableFormBuilder < FoundationRailsHelper::FormBuilder
    def translatable_fields(&block)
      @object.globalize_locales.map do |locale|
        Globalize.with_locale(locale) do
          fields_for(:translations, @object.translations.where(locale: locale).first_or_initialize, builder: TranslationsFieldsBuilder) do |translations_form|
            @template.concat translations_form.hidden_field(
              :_destroy,
              value: !@template.enable_locale?(@object, locale),
              class: "destroy_locale",
              data: { locale: locale })

            @template.concat translations_form.hidden_field(:locale, value: locale)

            yield translations_form
          end
        end
      end.join.html_safe
    end

  end

  class TranslationsFieldsBuilder < FoundationRailsHelper::FormBuilder
    %i[text_field text_area cktext_area].each do |field|
      define_method field do |attribute, options = {}|
        super attribute, translations_options(options)
      end
    end

    private

      def translations_options(options)
        @template.merge_translatable_field_options(options, @object.locale)
      end
  end
end
