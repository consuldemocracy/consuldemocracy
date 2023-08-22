require "airbrake/delayed_job" if defined?(Delayed)

Airbrake.configure do |config|
  config.host = Rails.application.secrets.errbit_host
  config.project_id = Rails.application.secrets.errbit_project_id
  config.project_key = Rails.application.secrets.errbit_project_key

  config.environment = Rails.env
  config.ignore_environments = %w[development test]

  config.performance_stats = false
  config.job_stats = false
  config.query_stats = false
  config.remote_config = false
end

Airbrake.add_filter do |notice|
  ignorables = [
    "AbstractController::ActionNotFound",
    "ActionController::RoutingError",
    "ActionController::InvalidAuthenticityToken",
    "ActionController::UnknownFormat",
    "ActionController::BadRequest",
    "ActionDispatch::Cookies::CookieOverflow",
    "ActionView::Template::Error",
    "ActiveRecord::RecordNotFound",
    "Apartment::TenantNotFound",
    "ArgumentError",
    "FeatureFlags::FeatureDisabled",
    "SignalException"
  ]
  notice.ignore! if ignorables.include? notice[:errors].first[:type]
end
