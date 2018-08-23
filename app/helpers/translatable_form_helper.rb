module TranslatableFormHelper
  def translatable_form_for(record_or_record_path, options = {})
    object = record_or_record_path.is_a?(Array) ? record_or_record_path.last : record_or_record_path

    form_for(record_or_record_path, options.merge(builder: TranslatableFormBuilder)) do |f|

      object.globalize_locales.each do |locale|
        concat translation_enabled_tag(locale, enable_locale?(object, locale))
      end

      yield(f)
    end
  end

  def merge_translatable_field_options(options, locale)
    options.merge(
      class: "#{options[:class]} js-globalize-attribute".strip,
      style: display_translation?(locale),
      data:  options.fetch(:data, {}).merge(locale: locale),
      label_options: {
        class: "#{options[:class]} js-globalize-attribute".strip,
        style: display_translation?(locale),
        data:  (options.dig(:label_options, :data) || {}) .merge(locale: locale)
      }
    )
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
            final_options = @template.merge_translatable_field_options(options, locale)
            @template.concat send(field_type, "#{method}_#{locale}", final_options)
          end
        end
      end
    end
end
