class Admin::BaseController < ApplicationController
  layout 'admin'
  before_action :authenticate_user!

  skip_authorization_check
  before_action :verify_administrator
  before_action :set_current_tenant
  before_action :get_tenants

  private

    def verify_administrator
      raise CanCan::AccessDenied unless current_user.try(:administrator?)
    end

    def set_current_tenant
      if session[:current_tenant].nil?
        session[:current_tenant] = Tenant.find_by(subdomain: Apartment::Tenant.current)
      end
    end

    def get_tenants
      @tenants = Tenant.all.order("LOWER(name)")
    end

end
