class Admin::Tenants::FormComponent < ApplicationComponent
  attr_reader :tenant

  def initialize(tenant)
    @tenant = tenant
  end
end
