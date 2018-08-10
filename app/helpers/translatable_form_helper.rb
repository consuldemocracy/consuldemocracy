module TranslatableFormHelper
  def translatable_form_for(record, options = {})
    object = record.is_a?(Array) ? record.last : record

    form_for(record, options.merge(builder: TranslatableFormBuilder)) do |f|

      object.globalize_locales.each do |locale|
        concat translation_enabled_tag(locale, enable_locale?(object, locale))
      end

      yield(f)
    end
  end
end

class TranslatableFormBuilder < FoundationRailsHelper::FormBuilder

  def translatable_text_field(method, options = {})
    translatable_field(:text_field, method, options)
  end
  def translatable_text_area(method, options = {})
    translatable_field(:text_area, method, options)
  end

  private

    def translatable_field(field_type, method, options = {})
      @template.capture do
        @object.globalize_locales.each do |locale|
          Globalize.with_locale(locale) do
            final_options = options.merge(
              class: (options.fetch(:class, "") + " js-globalize-attribute"),
              style: @template.display_translation?(locale),
              data:  options.fetch(:data, {}).merge(locale: locale),
              label: false
            )

            @template.concat send(field_type, "#{method}_#{locale}", final_options)
          end
        end
      end
    end
end
