class Admin::Tenants::ToggleHiddenComponent < ApplicationComponent
  attr_reader :tenant

  def initialize(tenant)
    @tenant = tenant
  end

  private

    def action
      if enabled?
        :hide
      else
        :restore
      end
    end

    def options
      {
        method: :put,
        "aria-label": t("admin.tenants.index.enable", tenant: tenant.name)
      }
    end

    def enabled?
      !tenant.hidden?
    end
end
