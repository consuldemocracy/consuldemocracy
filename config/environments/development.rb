Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.default_url_options = { host: 'smtp.mailgun.org', port: 2525 }
  config.action_mailer.asset_host = "http://smtp.mailgun.org:2525"

  # Deliver emails to a development mailbox at /letter_opener
  config.action_mailer.asset_host = "http://postmaster@sandbox5dde5b9b64e84ff194257e41b6495c81.mailgun.org"
  config.action_mailer.delivery_method = :smtp
  # SMTP settings for gmail
  config.action_mailer.smtp_settings = {
   :address              => "postmaster@sandbox5dde5b9b64e84ff194257e41b6495c81.mailgun.org",
   :port                 => 587,
   :user_name            => "smtp.mailgun.org",
   :password             => "97816ccf3aa3cc8a57d8ccd57381db7b",
   :authentication       => "plain",
  :enable_starttls_auto => true
  }
  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Asset digests allow you to set far-future HTTP expiration dates on all assets,
  # yet still be able to expire them through the digest params.
  config.assets.digest = true

  # Adds additional error checking when serving assets at runtime.
  # Checks for improperly declared sprockets dependencies.
  # Raises helpful error messages.
  config.assets.raise_runtime_errors = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  config.cache_store = :dalli_store

  config.after_initialize do
    Bullet.enable = true
    Bullet.bullet_logger = true
    if ENV['BULLET']
      Bullet.rails_logger = true
      Bullet.add_footer = true
    end
  end
end
