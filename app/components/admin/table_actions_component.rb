class Admin::TableActionsComponent < ApplicationComponent
  attr_reader :record, :options

  def initialize(record, **options)
    @record = record
    @options = options
  end

  def action(action_name, **args)
    render Admin::ActionComponent.new(action_name, record, "aria-label": true, **args)
  end

  private

    def actions
      options[:actions] || [:edit, :destroy]
    end

    def edit_text
      options[:edit_text]
    end

    def edit_path
      options[:edit_path]
    end

    def edit_options
      options[:edit_options] || {}
    end

    def destroy_text
      options[:destroy_text]
    end

    def destroy_path
      options[:destroy_path]
    end

    def destroy_options
      {
        method: :delete,
        confirm: options[:destroy_confirmation] || true
      }.merge(options[:destroy_options] || {})
    end
end
