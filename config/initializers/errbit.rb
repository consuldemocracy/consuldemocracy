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
end

Airbrake.add_filter do |notice|
  ignorables = [
    "ActiveRecord::RecordNotFound",
    "ActionController::RoutingError",
    "FeatureFlags::FeatureDisabled",
    "AbstractController::ActionNotFound",
    "SignalException"
  ]
  notice.ignore! if ignorables.include? notice[:errors].first[:type]
end
