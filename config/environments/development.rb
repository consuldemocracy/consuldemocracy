Warning[:deprecated] = true
require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded any time
  # it changes. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.enable_reloading = true

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable server timing
  config.server_timing = true

  # Enable/disable caching. By default caching is disabled.
  # Run rails dev:cache to toggle caching.
  if Rails.root.join("tmp/caching-dev.txt").exist?
    config.action_controller.perform_caching = true
    config.action_controller.enable_fragment_cache_logging = true

    config.cache_store = :memory_store, { namespace: proc { Tenant.current_schema }}
    config.public_file_server.headers = {
      "Cache-Control" => "public, max-age=#{2.days.to_i}"
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  # Allow accessing the application through a domain so subdomains can be used
  config.hosts << "consuldev.communitychoices.scot"
  config.hosts << /.*\.lvh\.me/

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.default_url_options = { host: "localhost", port: 3000 }

  # Deliver emails to a development mailbox at /letter_opener
  config.action_mailer.delivery_method = :letter_opener
  config.action_mailer.perform_caching = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise exceptions for disallowed deprecations.
  config.active_support.disallowed_deprecation = :raise

  # Tell Active Support which deprecation messages to disallow.
  config.active_support.disallowed_deprecation_warnings = []

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true

  # Highlight code that enqueued background job in logs.
  config.active_job.verbose_enqueue_logs = true

  # Suppress logger output for asset requests.
  config.assets.quiet = true

  # Raises error for missing translations.
  # config.i18n.raise_on_missing_translations = true

  # Annotate rendered view with file names.
  # config.action_view.annotate_rendered_view_with_filenames = true

  config.eager_load_paths << "#{Rails.root}/spec/mailers/previews"
  config.action_mailer.preview_paths << "#{Rails.root}/spec/mailers/previews"
  config.action_mailer.preview_path = "#{Rails.root}/spec/mailers/previews"

  config.log_level = :debug

  # Limit size of local logs
  # TODO: replace with config.log_file_size after upgrading to Rails 7.1
  logger = ActiveSupport::Logger.new(config.default_log_file, 1, 100.megabytes)
  logger.formatter = config.log_formatter
  config.logger = ActiveSupport::TaggedLogging.new(logger)

  # Uncomment if you wish to allow Action Cable access from any origin.
  # config.action_cable.disable_request_forgery_protection = true

      # Copy the generate key set and set them as environment variables
    puts "SALT COMINGUP #{ENV['ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT']}"
    config.active_record.encryption.primary_key = ENV['ACTIVE_RECORD_PRIMARY_KEY']
    config.active_record.encryption.deterministic_key = ENV['ACTIVE_RECORD_DETERMINISTIC_KEY']
    config.active_record.encryption.key_derivation_salt = ENV['ACTIVE_RECORD_KEY_SALT']

end

require Rails.root.join("config", "environments", "custom", "development")
