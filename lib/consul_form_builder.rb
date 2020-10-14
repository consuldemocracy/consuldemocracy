class ConsulFormBuilder < FoundationRailsHelper::FormBuilder
  include ActionView::Helpers::SanitizeHelper

  def enum_select(attribute, options = {}, html_options = {})
    choices = object.class.send(attribute.to_s.pluralize).keys.map do |name|
      [object.class.human_attribute_name("#{attribute}.#{name}"), name]
    end

    select attribute, choices, options, html_options
  end

  %i[text_field text_area date_field number_field password_field email_field].each do |field|
    define_method field do |attribute, options = {}|
      label_with_hint(attribute, options.merge(label_options: label_options_for(options))) +
        super(attribute, options.merge(
          label: false, hint: nil,
          aria: { describedby: help_text_id(attribute, options) }
        ))
    end
  end

  def check_box(attribute, options = {})
    if options[:label] != false
      label = tag.span sanitize(label_text(attribute, options[:label])), class: "checkbox"

      super(attribute, options.merge(label: label, label_options: label_options_for(options)))
    else
      super
    end
  end

  def radio_button(attribute, tag_value, options = {})
    default_label = object.class.human_attribute_name("#{attribute}_#{tag_value}")

    super(attribute, tag_value, { label: default_label }.merge(options))
  end

  def select(attribute, choices, options = {}, html_options = {})
    label_with_hint(attribute, options.merge(label_options: label_options_for(options))) +
      super(attribute, choices, options.merge(label: false, hint: nil), html_options.merge({
        aria: { describedby: help_text_id(attribute, options) }
      }))
  end

  private

    def custom_label(attribute, text, options)
      if text == false
        super
      else
        super(attribute, sanitize(label_text(attribute, text)), options)
      end
    end

    def label_with_hint(attribute, options)
      custom_label(attribute, options[:label], options[:label_options]) +
        help_text(attribute, options)
    end

    def label_text(attribute, text)
      if text.nil? || text == true
        default_label_text(object, attribute)
      else
        text
      end
    end

    def label_options_for(options)
      label_options = options[:label_options] || {}

      if options[:id]
        { for: options[:id] }.merge(label_options)
      else
        label_options
      end
    end

    def help_text(attribute, options)
      if options[:hint]
        tag.span options[:hint], class: "help-text", id: help_text_id(attribute, options)
      end
    end

    def help_text_id(attribute, options)
      if options[:hint]
        "#{custom_label(attribute, nil, nil).match(/for="([^"]+)"/)[1]}-help-text"
      end
    end
end
