class Admin::Tenants::NewComponent < ApplicationComponent
  include Header
  attr_reader :tenant
  delegate :current_user, to: :helpers

  def initialize(tenant)
    @tenant = tenant
  end

  def title
    t("admin.tenants.new.title")
  end
end
