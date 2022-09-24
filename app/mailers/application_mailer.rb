class ApplicationMailer < ActionMailer::Base
  helper :settings
  helper :application
  helper :mailer
  default from: proc { "#{Setting["mailer_from_name"]} <#{Setting["mailer_from_address"]}>" }
  layout "mailer"
  before_action :set_asset_host

  def default_url_options
    if Tenant.default?
      super
    else
      super.merge(host: host_with_subdomain_for(super[:host]))
    end
  end

  def set_asset_host
    self.asset_host ||= root_url.delete_suffix("/")
  end

  private

    def host_with_subdomain_for(host)
      if host == "localhost"
        "#{Tenant.current_schema}.lvh.me"
      else
        "#{Tenant.current_schema}.#{host}"
      end
    end
end
