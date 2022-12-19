class Admin::MenuTenantComponent < ApplicationComponent
  include LinkListHelper
  delegate :can?, to: :helpers

  private

    def tenants_link
      if can?(:read, Tenant)
        [
          t("admin.menu.multitenancy"),
          admin_tenants_path,
          controller_name == "tenants"
        ]
      end
    end
end
