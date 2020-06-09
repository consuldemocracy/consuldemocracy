class Admin::TableActionsComponent < ApplicationComponent
  attr_reader :record, :options

  def initialize(record, **options)
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

    def destroy_text
      options[:destroy_text] || t("admin.actions.delete")
    end
end
