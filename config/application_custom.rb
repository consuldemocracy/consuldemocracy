module Consul
  class Application < Rails::Application
    # this is where we set slovenian as the default (and only) locale
    config.i18n.default_locale = "sl-SI"
    available_locales = [
      "sl",
      "sl-SI",
      "en"
    ]
    config.i18n.available_locales = available_locales

    # # Set different path for compiled assets in production.
    # # This is required so we can properly mount the volume
    # # in several different containers.
    # config.assets.prefix = "../../../../pvc"
  end
end
