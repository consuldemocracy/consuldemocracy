module Consul
  class Application < Rails::Application
    config.i18n.default_locale = :he
    available_locales = [
      "he",
      "en"]
    config.i18n.available_locales = available_locales
    config.i18n.fallbacks = {
      "he"    => "en"
	}
    config.i18n.load_path += Dir[Rails.root.join("config", "locales", "**", "*.{rb,yml}")]
    config.i18n.load_path += Dir[Rails.root.join("config", "locales", "custom", "**", "*.{rb,yml}")]
    config.after_initialize { Globalize.set_fallbacks_to_all_available_locales }
    config.assets.paths << Rails.root.join("app", "assets", "fonts")
    config.active_record.raise_in_transactional_callbacks = true
    config.autoload_paths << Rails.root.join("lib")
    config.time_zone = "Israel"
    config.active_job.queue_adapter = :delayed_job
    config.autoload_paths << "#{Rails.root}/app/controllers/custom"
    config.autoload_paths << "#{Rails.root}/app/models/custom"
    config.paths["app/views"].unshift(Rails.root.join("app", "views", "custom"))
  end
end

