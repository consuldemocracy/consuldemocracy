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
    if options[:label] == false
      super
    else
      label = tag.span sanitized_label_text(attribute, options[:label]), class: "checkbox"

      super(attribute, options.merge(
        label: label,
        label_options: { class: "checkbox-label" }.merge(label_options_for(options))
      ))
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

  # Generates a select dropdown based on a collection of objects.
  # Integrates with label_with_hint for consistent label and hint display.
  #
 def collection_select(attribute, collection, value_method, text_method, options = {}, html_options = {})
  # Extract include_blank option if present
  include_blank = options.delete(:include_blank)

  # Generate the label and hint text using the existing helper
  label_and_hint_html = label_with_hint(attribute, options.merge(label_options: label_options_for(options)))

  # Generate the collection_select input using the parent implementation
  # Merge options:
  # - label: false, hint: nil -> Prevent duplicate rendering as they are handled above.
  # - aria: describedby -> Link hint text for accessibility.
  select_html = super(
    attribute,
    collection,
    value_method,
    text_method,
    options.merge(label: false, hint: nil, include_blank: include_blank), # Options for the core helper
    html_options.merge(aria: { describedby: help_text_id(attribute, options) }) # HTML attributes for the tag
  )

  # Combine the label/hint and the select input
  label_and_hint_html + select_html
end

  # --- END NEW collection_select METHOD ---  
  

  private

    def custom_label(attribute, text, options)
      if text == false
        super
      else
        super(attribute, sanitized_label_text(attribute, text), options)
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

    def sanitized_label_text(attribute, text)
      sanitize(label_text(attribute, text), attributes: allowed_attributes)
    end

    def allowed_attributes
      self.class.sanitized_allowed_attributes + ["target"]
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
      if options[:hint].present?
        tag.span options[:hint], class: "help-text", id: help_text_id(attribute, options)
      end
    end

    def help_text_id(attribute, options)
      if options[:hint].present?
        "#{custom_label(attribute, "Example", nil).match(/for="([^"]+)"/)[1]}-help-text"
      end
    end
end
