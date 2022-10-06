class ApplicationMailer < ActionMailer::Base
  helper :application, :layouts, :mailer, :settings
  default from: proc { "#{Setting["mailer_from_name"]} <#{Setting["mailer_from_address"]}>" }
  layout "mailer"
  before_action :set_asset_host

  def default_url_options
    Tenant.current_url_options
  end

  def set_asset_host
    self.asset_host ||= root_url.delete_suffix("/")
  end
end
