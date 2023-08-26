class Admin::Tenants::FormComponent < ApplicationComponent
  attr_reader :tenant

  def initialize(tenant)
    @tenant = tenant
  end

  private

    def attribute_name(attribute)
      Tenant.human_attribute_name(attribute)
    end

    def domain
      Tenant.default_domain
    end

    def schema_labels_per_schema_type
      Tenant.schema_types.keys.to_h do |schema_type|
        [:"schema_type_#{schema_type}", attribute_name(schema_type)]
      end
    end
end
