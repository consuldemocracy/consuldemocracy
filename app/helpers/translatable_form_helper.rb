module TranslatableFormHelper
  def translatable_form_for(record, options = {})
    options_full = options.merge(builder: TranslatableFormBuilder)
    form_for(record, options_full) do |f|
      yield(f)
    end
  end

  def translations_interface_enabled?
    Setting["feature.translation_interface"].present? || backend_translations_enabled?
  end

  def backend_translations_enabled?
    (controller.class.parents & [Admin, Management, Valuation, Tracking]).any?
  end

  def highlight_translation_html_class
    "highlight" if translations_interface_enabled?
  end

  class TranslatableFormBuilder < FoundationRailsHelper::FormBuilder
    attr_accessor :translations

    def translatable_fields(&block)
      @translations = {}
      visible_locales.map do |locale|
        @translations[locale] = translation_for(locale)
      end
      visible_locales.map do |locale|
        Globalize.with_locale(locale) { fields_for_locale(locale, &block) }
      end.join.html_safe
    end

    private

      def fields_for_locale(locale, &block)
        fields_for_translation(@translations[locale]) do |translations_form|
          @template.content_tag :div, translations_options(translations_form.object, locale) do
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
          translation.mark_for_destruction
        end
      end

      def highlight_translation_html_class
        @template.highlight_translation_html_class
      end

      def translations_options(resource, locale)
        {
          class: "translatable-fields js-globalize-attribute #{highlight_translation_html_class}",
          style: @template.display_translation_style(resource.globalized_model, locale),
          data:  { locale: locale }
        }
      end

      def no_other_translations?(translation)
        (@object.translations - [translation]).reject(&:_destroy).empty?
      end

      def visible_locales
        if @template.translations_interface_enabled?
          @object.globalize_locales
        else
          [I18n.locale]
        end
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
