class Tenant < ActiveRecord::Base
  validates :subdomain, uniqueness: true

  after_create :create_tenant
  after_destroy :destroy_tenant

  private
    def create_tenant
      unless subdomain == "public"
        Apartment::Tenant.create(subdomain)
      end
    end

    def destroy_tenant
      Apartment::Tenant.drop(subdomain)
    end
end
