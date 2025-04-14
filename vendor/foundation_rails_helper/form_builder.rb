# frozen_string_literal: true

# Copyright (c) 2015 Sébastien Gruhier (http://xilinus.com/)
# MIT License
# Vendored copy from https://github.com/sgruhier/foundation_rails_helper/blob/master/lib/foundation_rails_helper/form_builder.rb
#
# This file was vendored to work around the Rails 7.1 incompatibility,
# since the `foundation_rails_helper` gem is no longer maintained.
#
# See LICENSE in vendor/foundation_rails_helper/LICENSE

require 'action_view/helpers'

module FoundationRailsHelper
  class FormBuilder < ActionView::Helpers::FormBuilder
    include ActionView::Helpers::TagHelper
    include ActionView::Helpers::OutputSafetyHelper
    %w(file_field email_field text_field text_area telephone_field phone_field
       url_field number_field date_field datetime_field datetime_local_field
       month_field week_field time_field range_field search_field color_field)
      .each do |method_name|
      define_method(method_name) do |*args|
        attribute = args[0]
        options   = args[1] || {}
        field(attribute, options) do |opts|
          super(attribute, opts)
        end
      end
    end

    def label(attribute, text = nil, options = {})
      if error?(attribute)
        options[:class] ||= ''
        options[:class] += ' is-invalid-label'
      end

      super(attribute, (text || '').html_safe, options)
    end

    # rubocop:disable LineLength
    def check_box(attribute, options = {}, checked_value = '1', unchecked_value = '0')
      custom_label(attribute, options[:label], options[:label_options]) do
        options.delete(:label)
        options.delete(:label_options)
        super(attribute, options, checked_value, unchecked_value)
      end + error_and_help_text(attribute, options)
    end
    # rubocop:enable LineLength

    def radio_button(attribute, tag_value, options = {})
      options[:label_options] ||= {}
      label_options = options.delete(:label_options).merge!(value: tag_value)
      label_text = options.delete(:label)
      l = label(attribute, label_text, label_options) unless label_text == false
      r = @template.radio_button(@object_name, attribute, tag_value,
                                 objectify_options(options))

      "#{r}#{l}".html_safe
    end

    def password_field(attribute, options = {})
      field attribute, options do |opts|
        super(attribute, opts.merge(autocomplete: :off))
      end
    end

    def datetime_select(attribute, options = {}, html_options = {})
      field attribute, options, html_options do |html_opts|
        super(attribute, options, html_opts.merge(autocomplete: :off))
      end
    end

    def date_select(attribute, options = {}, html_options = {})
      field attribute, options, html_options do |html_opts|
        super(attribute, options, html_opts.merge(autocomplete: :off))
      end
    end

    # rubocop:disable LineLength
    def time_zone_select(attribute, priorities = nil, options = {}, html_options = {})
      field attribute, options, html_options do |html_opts|
        super(attribute, priorities, options,
              html_opts.merge(autocomplete: :off))
      end
    end
    # rubocop:enable LineLength

    def select(attribute, choices, options = {}, html_options = {})
      field attribute, options, html_options do |html_opts|
        html_options[:autocomplete] ||= :off
        super(attribute, choices, options, html_opts)
      end
    end

    # rubocop:disable LineLength, ParameterLists
    def collection_select(attribute, collection, value_method, text_method, options = {}, html_options = {})
      field attribute, options, html_options do |html_opts|
        html_options[:autocomplete] ||= :off
        super(attribute, collection, value_method, text_method, options,
              html_opts)
      end
    end

    def grouped_collection_select(attribute, collection, group_method, group_label_method, option_key_method, option_value_method, options = {}, html_options = {})
      field attribute, options, html_options do |html_opts|
        html_options[:autocomplete] ||= :off
        super(attribute, collection, group_method, group_label_method,
              option_key_method, option_value_method, options, html_opts)
      end
    end
    # rubocop:enable LineLength, ParameterLists

    def autocomplete(attribute, url, options = {})
      field attribute, options do |opts|
        opts.merge!(update_elements: opts[:update_elements],
                    min_length: 0, value: object.send(attribute))
        autocomplete_field(attribute, url, opts)
      end
    end

    def submit(value = nil, options = {})
      options[:class] ||= FoundationRailsHelper.configuration.button_class
      super(value, options)
    end

    def error_for(attribute, options = {})
      return unless error?(attribute)

      class_name = 'form-error is-visible'
      class_name += " #{options[:class]}" if options[:class]

      error_messages = object.errors[attribute].join(', ')
      error_messages = error_messages.html_safe if options[:html_safe_errors]
      content_tag(:small, error_messages,
                  class: class_name.sub('is-invalid-input', ''))
    end

    private

    def error?(attribute)
      object.respond_to?(:errors) && !object.errors[attribute].blank?
    end

    def default_label_text(object, attribute)
      if object.class.respond_to?(:human_attribute_name)
        return object.class.human_attribute_name(attribute)
      end

      attribute.to_s.humanize
    end

    def custom_label(attribute, text, options)
      return block_given? ? yield.html_safe : ''.html_safe if text == false

      text = default_label_text(object, attribute) if text.nil? || text == true
      text = safe_join([yield, text.html_safe]) if block_given?
      label(attribute, text, options || {})
    end

    def column_classes(options)
      classes = SizeClassCalculator.new(options).classes
      classes + ' columns'
    end

    def tag_from_options(name, options)
      return ''.html_safe unless options && options[:value].present?

      content_tag(:div,
                  content_tag(:span, options[:value], class: name),
                  class: column_classes(options).to_s)
    end

    def decrement_input_size(input, column, options)
      return unless options.present? && options.key?(column)

      input.send("#{column}=",
                 (input.send(column) - options.fetch(column).to_i))
      input.send('changed?=', true)
    end

    def calculate_input_size(prefix_options, postfix_options)
      input_size =
        OpenStruct.new(changed?: false, small: 12, medium: 12, large: 12)
      %w(small medium large).each do |size|
        decrement_input_size(input_size, size.to_sym, prefix_options)
        decrement_input_size(input_size, size.to_sym, postfix_options)
      end

      input_size
    end

    def wrap_prefix_and_postfix(block, prefix_options, postfix_options)
      prefix = tag_from_options('prefix', prefix_options)
      postfix = tag_from_options('postfix', postfix_options)

      input_size = calculate_input_size(prefix_options, postfix_options)
      klass = column_classes(input_size.marshal_dump).to_s
      input = content_tag(:div, block, class: klass)

      return block unless input_size.changed?
      content_tag(:div, prefix + input + postfix, class: 'row collapse')
    end

    def error_and_help_text(attribute, options = {})
      html = ''
      if options[:help_text]
        html += content_tag(:p, options[:help_text], class: 'help-text')
      end
      html += error_for(attribute, options) || ''
      html.html_safe
    end

    def field_label(attribute, options)
      return ''.html_safe unless auto_labels || options[:label]
      custom_label(attribute, options[:label], options[:label_options])
    end

    def field(attribute, options, html_options = nil)
      html = field_label(attribute, options)
      class_options = html_options || options

      if error?(attribute)
        class_options[:class] = class_options[:class].to_s
        class_options[:class] += ' is-invalid-input'
      end

      options.delete(:label)
      options.delete(:label_options)
      help_text = options.delete(:help_text)
      prefix = options.delete(:prefix)
      postfix = options.delete(:postfix)

      html += wrap_prefix_and_postfix(yield(class_options), prefix, postfix)
      html + error_and_help_text(attribute, options.merge(help_text: help_text))
    end

    def auto_labels
      if @options[:auto_labels].nil?
        FoundationRailsHelper.configuration.auto_labels
      else
        @options[:auto_labels]
      end
    end
  end
end
