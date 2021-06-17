Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable/disable caching. By default caching is disabled.
  if Rails.root.join("tmp/caching-dev.txt").exist?
    config.action_controller.perform_caching = true

    config.cache_store = :memory_store
    config.public_file_server.headers = {
      "Cache-Control" => "public, max-age=172800"
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.default_url_options = { host: "localhost", port: 3000 }
  config.action_mailer.asset_host = "http://localhost:3000"

  # Deliver emails to a development mailbox at /letter_opener
  config.action_mailer.delivery_method = :letter_opener
  config.action_mailer.perform_caching = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = false

  # Asset digests allow you to set far-future HTTP expiration dates on all assets,
  # yet still be able to expire them through the digest params.
  config.assets.digest = false

  # We allow connecting from our localhost supporting different VMBOX (Vagrant NAT; e.g)
  config.web_console.whitelisted_ips = ['10.0.0.0/8', '172.16.0.0/12', '192.168.0.0/16']

  # Adds additional error checking when serving assets at runtime.
  # Checks for improperly declared sprockets dependencies.
  # Raises helpful error messages.
  config.assets.raise_runtime_errors = true
  # Suppress logger output for asset requests.
  config.assets.quiet = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  config.cache_store = :dalli_store
  config.action_mailer.preview_path = "#{Rails.root}/spec/mailers/previews"

  config.after_initialize do
    Bullet.enable = true
    Bullet.bullet_logger = true
    if ENV["BULLET"]
      Bullet.rails_logger = true
      Bullet.add_footer = true
    end
  end
  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  # config.file_watcher = ActiveSupport::EventedFileUpdateChecker

  #
  # Ips de acceso de gestion, ellas pasaran directamente al sign_in, en otro caso serán redirigidas
  # a la URL de negociación, se pueden separar por ";" en caso de existir varias
  config.participacion_management_ip = Rails.application.secrets.participacion_management_ip

  # URL de renegociacion en el caso de que la IP no sea valida, para que se gestione una renegociacion
  # de sesion, en cualquier caso siempre entra por aqui, sera el portal de participacion el que se
  # encarga de comprobar si el resultado es valido
  config.participacion_renegotiation = Rails.application.secrets.participacion_renegotiation

  # Mantiene el token seguro que se negocia con la aplicacion para la conexión remota
  config.participacion_xauth_secret = Rails.application.secrets.participacion_xauth_secret

  # Mantiene las IPs de acceso remoto para la autenticacion
  config.participacion_xauth_origin = Rails.application.secrets.participacion_xauth_origin

  # targetOrigin para los pushmessage cuando se embebe como iframe
  config.participacion_push_target_origin = Rails.application.secrets.participacion_push_target_origin

  # El source del iframe que tenemos
  config.participacion_iframe_source = Rails.application.secrets.participacion_iframe_source


end
