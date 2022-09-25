class Admin::Tenants::EditComponent < ApplicationComponent
  include Header
  attr_reader :tenant

  def initialize(tenant)
    @tenant = tenant
  end

  def title
    tenant.name
  end
end
