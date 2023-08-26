class ApplicationMailer < ActionMailer::Base
  helper :application, :layouts, :mailer, :settings
  default from: proc { "#{Setting["mailer_from_name"]} <#{Setting["mailer_from_address"]}>" }
  layout "mailer"
  before_action :set_asset_host
  before_action :set_variant
  after_action :set_smtp_settings

  def default_url_options
    Tenant.current_url_options
  end

  def set_asset_host
    self.asset_host ||= root_url.delete_suffix("/")
  end

  def set_variant
    lookup_context.variants = [Tenant.current_schema.to_sym]
  end

  def set_smtp_settings
    unless Tenant.default?
      mail.delivery_method.settings.merge!(Tenant.current_secrets.smtp_settings.to_h)
    end
  end
end
