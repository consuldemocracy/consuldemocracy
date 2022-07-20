require "airbrake/delayed_job" if defined?(Delayed)

Airbrake.configure do |config|
  config.host = Rails.application.secrets.errbit_host
  config.project_id = Rails.application.secrets.errbit_project_id
  config.project_key = Rails.application.secrets.errbit_project_key

  config.environment = Rails.env
  config.ignore_environments = %w[development test]
end

Airbrake.add_filter do |notice|
  ignorables = [
    "AbstractController::ActionNotFound",
    "ActionController::RoutingError",
    "ActionController::InvalidAuthenticityToken",
    "ActionController::UnknownFormat",
    "ActionDispatch::Cookies::CookieOverflow",
    "ActionView::Template::Error",
    "ActiveRecord::RecordNotFound",
    "ArgumentError",
    "FeatureFlags::FeatureDisabled",
    "SignalException"
  ]
  notice.ignore! if ignorables.include? notice[:errors].first[:type]
end
