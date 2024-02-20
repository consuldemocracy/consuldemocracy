require "airbrake/delayed_job" if defined?(Delayed)

Airbrake.configure do |config|
  config.host = Rails.application.secrets.errbit_host
  config.project_id = Rails.application.secrets.errbit_project_id
  config.project_key = Rails.application.secrets.errbit_project_key

  config.environment = Rails.env
  config.ignore_environments = %w[development test]

  if config.host.blank? || config.project_id.blank? || config.project_key.blank?
    config.ignore_environments += [Rails.env]
  end

  config.performance_stats = false
  config.job_stats = false
  config.query_stats = false
  config.remote_config = false

  config.blocklist_keys = Rails.application.config.filter_parameters
end

Airbrake.add_filter do |notice|
  ignorables = [
    "AbstractController::ActionNotFound",
    "ActionController::RoutingError",
    "ActionController::InvalidAuthenticityToken",
    "ActionController::UnknownFormat",
    "ActionController::BadRequest",
    "ActionDispatch::Cookies::CookieOverflow",
    "ActionDispatch::Http::MimeNegotiation::InvalidType",
    "ActionView::Template::Error",
    "ActiveRecord::RecordNotFound",
    "Apartment::TenantNotFound",
    "ArgumentError",
    "FeatureFlags::FeatureDisabled",
    "SignalException"
  ]

  notice.ignore! if ignorables.include? notice[:errors].first[:type]
end

if Rails.application.secrets.errbit_self_hosted_ssl.present?
  # Patch from: https://mensfeld.pl/2016/05/setting-up-errbit-reporter-airbrake-v5-gem-to-work-with-self-signed-https-certificate/
  module Patches
    module Airbrake
      module SyncSender
        def build_https(uri)
          super.tap do |req|
            req.verify_mode = OpenSSL::SSL::VERIFY_NONE
          end
        end
      end
    end
  end

  Airbrake::SyncSender.prepend(::Patches::Airbrake::SyncSender)
end
