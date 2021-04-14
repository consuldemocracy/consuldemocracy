Rails.application.configure do
    config.action_mailer.delivery_method = Rails.application.secrets.mailer_delivery_method || :smtp
    config.action_mailer.smtp_settings = Rails.application.secrets.smtp_settings
end