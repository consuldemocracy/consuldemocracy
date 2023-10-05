class Admin::ActionComponent < ApplicationComponent
  include Admin::Namespace
  attr_reader :action, :record, :options

  def initialize(action, record, **options)
    @action = action
    @record = record
    @options = options
  end

  private

    def button?
      options[:method] && options[:method] != :get
    end

    def text
      action_key = if action == :destroy
                     :delete
                   else
                     action
                   end

      options[:text] || t("admin.actions.#{action_key}")
    end

    def path
      options[:path] || default_path
    end

    def html_options
      {
        class: html_class,
        id: (dom_id(record, action) if record.respond_to?(:to_key)),
        "aria-describedby": describedby,
        "aria-label": label,
        data: {
          confirm: confirmation_text,
          disable_with: (text if button?)
        }
      }.merge(options.except(:"aria-describedby", :"aria-label", :class, :confirm, :path, :text))
    end

    def html_class
      "admin-action #{options[:class] || "#{action.to_s.gsub("_", "-")}-link"}".strip
    end

    def describedby
      if options[:"aria-describedby"] == true
        "#{dom_id(record, action)}_descriptor"
      else
        options[:"aria-describedby"]
      end
    end

    def label
      if options[:"aria-label"] == true
        t("admin.actions.label", action: text, name: record_name)
      else
        options[:"aria-label"]
      end
    end

    def confirmation_text
      if options[:confirm] == true
        if action == :destroy
          t("admin.actions.confirm_delete", name: record_name)
        else
          t("admin.actions.confirm_action", action: text, name: record_name)
        end
      elsif options[:confirm].respond_to?(:call)
        options[:confirm].call(record_name)
      else
        options[:confirm]
      end
    end

    def record_name
      if record.respond_to?(:human_name)
        record.human_name
      else
        record.to_s.humanize
      end
    end

    def default_path
      if %i[answers configure destroy preview show].include?(action.to_sym)
        namespaced_polymorphic_path(namespace, record)
      else
        namespaced_polymorphic_path(namespace, record, { action: action }.merge(request.query_parameters))
      end
    end
end
