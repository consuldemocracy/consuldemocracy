module TenantVariants
  extend ActiveSupport::Concern

  included do
    before_action :set_tenant_variant
  end

  private

    def set_tenant_variant
      request.variant = Tenant.current_schema.to_sym
    end
end
