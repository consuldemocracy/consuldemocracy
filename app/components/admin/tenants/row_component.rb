class Admin::Tenants::RowComponent < ApplicationComponent
  attr_reader :tenant

  def initialize(tenant)
    @tenant = tenant
  end
end
