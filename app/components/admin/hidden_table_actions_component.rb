class Admin::HiddenTableActionsComponent < ApplicationComponent
  include TableActionLink
  attr_reader :record

  def initialize(record)
    @record = record
  end

  private

    def restore_text
      t("admin.actions.restore")
    end

    def restore_path
      action_path(:restore)
    end

    def confirm_hide_text
      t("admin.actions.confirm_hide")
    end

    def confirm_hide_path
      action_path(:confirm_hide)
    end

    def action_path(action)
      url_for({
        controller: "admin/hidden_#{record.model_name.plural}",
        action: action,
        id: record,
        only_path: true
      }.merge(request.query_parameters))
    end
end
