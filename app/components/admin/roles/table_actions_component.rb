class Admin::Roles::TableActionsComponent < ApplicationComponent
  include TableActionLink
  attr_reader :record, :actions

  def initialize(record, actions: [:destroy])
    @record = record
    @actions = actions
  end

  private

    def role
      record.class.name.tableize
    end

    def already_has_role?
      record.persisted?
    end

    def add_user_text
      t("admin.#{role}.#{role.singularize}.add")
    end

    def add_user_path
      {
        controller: "admin/#{role}",
        action: :create,
        user_id: record.user
      }
    end
end
