class Admin::TableActionsComponent < ApplicationComponent
  attr_reader :record, :options

  def initialize(record = nil, **options)
    @record = record
    @options = options
  end

  private

    def actions
      options[:actions] || [:edit, :destroy]
    end

    def edit_text
      options[:edit_text] || t("admin.actions.edit")
    end

    def edit_path
      options[:edit_path] || admin_polymorphic_path(record, action: :edit)
    end

    def destroy_text
      options[:destroy_text] || t("admin.actions.delete")
    end

    def destroy_path
      options[:destroy_path] || admin_polymorphic_path(record)
    end
end
