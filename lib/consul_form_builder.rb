class ConsulFormBuilder < FoundationRailsHelper::FormBuilder
  def enum_select(attribute, options = {}, html_options = {})
    choices = object.class.send(attribute.to_s.pluralize).keys.map do |name|
      [object.class.human_attribute_name("#{attribute}.#{name}"), name]
    end

    select attribute, choices, options, html_options
  end

  %i[text_field text_area cktext_area number_field password_field email_field].each do |field|
    define_method field do |attribute, options = {}|
      label_with_hint(attribute, options) +
        super(attribute, options.merge(label: false, hint: false))
    end
  end

  private

    def label_with_hint(attribute, options)
      custom_label(attribute, options[:label], options[:label_options]) +
        help_text(options[:hint])
    end

    def help_text(text)
      if text
        content_tag :span, text, class: "help-text"
      end
    end
end
