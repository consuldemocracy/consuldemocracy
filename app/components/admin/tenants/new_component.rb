class Admin::Tenants::NewComponent < ApplicationComponent
  include Header
  attr_reader :tenant
  use_helpers :current_user

  def initialize(tenant)
    @tenant = tenant
  end

  def title
    t("admin.tenants.new.title")
  end
end
