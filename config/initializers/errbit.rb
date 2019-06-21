Airbrake.configure do |config|
  config.host = Rails.application.secrets.errbit_host
  config.project_id = Rails.application.secrets.errbit_project_id
  config.project_key = Rails.application.secrets.errbit_project_key

  config.environment = Rails.env
  config.ignore_environments = %w[development test]
  config.ignore_environments += [Rails.env] if Rails.application.secrets.errbit_project_id.blank?
end
