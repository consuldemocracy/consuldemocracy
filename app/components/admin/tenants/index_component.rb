class Admin::Tenants::IndexComponent < ApplicationComponent
  include Header
  attr_reader :tenants

  def initialize(tenants)
    @tenants = tenants
  end

  def title
    t("admin.menu.multitenancy")
  end

  private

    def attribute_name(attribute)
      Tenant.human_attribute_name(attribute)
    end
end
