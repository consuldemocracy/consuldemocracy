class ConsulFormBuilder < FoundationRailsHelper::FormBuilder
  include ActionView::Helpers::SanitizeHelper

  def enum_select(attribute, options = {}, html_options = {})
    choices = object.class.send(attribute.to_s.pluralize).keys.map do |name|
      [object.class.human_attribute_name("#{attribute}.#{name}"), name]
    end

    select attribute, choices, options, html_options
  end

  %i[text_field date_field number_field password_field email_field].each do |field|
    define_method field do |attribute, options = {}|
      label_with_hint(attribute, options.merge(label_options: label_options_for(options))) +
        super(attribute, options.merge(
          label: false, hint: nil,
          aria: { describedby: help_text_id(attribute, options) }
        ))
    end
  end

  def text_area(attribute, options = {})
    options = speech_to_text_options(options)

    label_with_hint(attribute, options.merge(label_options: label_options_for(options))) +
      super(attribute, options.merge(
        label: false, hint: nil,
        aria: { describedby: help_text_id(attribute, options) }
      ))
  end

  def check_box(attribute, options = {})
    options_with_aria_error = aria_error_options(attribute).merge(options)

    if options[:label] == false
      super(attribute, options_with_aria_error)
    else
      label = tag.span sanitized_label_text(attribute, options[:label]), class: "checkbox"

      super(attribute, options_with_aria_error.merge(
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

  def error_for(attribute, ...)
    if error?(attribute)
      content_tag(:span, super, id: field_id(attribute, :error))
    end
  end

  def field(attribute, options, html_options = nil)
    if html_options
      super(attribute, options, aria_error_options(attribute).merge(html_options))
    else
      super(attribute, aria_error_options(attribute).merge(options))
    end
  end

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
        field_id(attribute, :help_text)
      end
    end

    def aria_error_options(attribute)
      if error?(attribute)
        { "aria-invalid" => true, "aria-errormessage" => field_id(attribute, :error) }
      else
        {}
      end
    end

    def speech_to_text_options(options)
      return options unless public_html_area?(options) && ::Llm::Config.speech_to_text_configured?

      options = options.dup
      options[:data] = speech_to_text_data.merge(options[:data] || {})
      options
    end

    def public_html_area?(options)
      classes = Array(options[:class]).flat_map { |value| value.to_s.split }
      classes.include?("html-area") && !classes.include?("admin")
    end

    def speech_to_text_data
      {
        speech_to_text_enabled: true,
        speech_to_text_endpoint: Rails.application.routes.url_helpers.speech_to_text_path,
        speech_to_text_locale: speech_to_text_locale,
        speech_to_text_label_idle: I18n.t("speech_to_text.button.idle"),
        speech_to_text_label_recording: I18n.t("speech_to_text.button.recording"),
        speech_to_text_label_loading: I18n.t("speech_to_text.button.loading"),
        speech_to_text_error_microphone_blocked: I18n.t("speech_to_text.button.microphone_blocked"),
        speech_to_text_error_unsupported_browser: I18n.t("speech_to_text.button.unsupported_browser"),
        speech_to_text_error_transcription_failed: I18n.t("speech_to_text.errors.transcription_failed")
      }
    end

    def speech_to_text_locale
      respond_to?(:locale) ? locale : I18n.locale
    end
end
