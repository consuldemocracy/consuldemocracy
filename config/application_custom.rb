module Consul
  class Application < Rails::Application
    config.i18n.available_locales = [:va, :es, :en]
    config.i18n.fallbacks = {'va' => 'es', 'en' => 'es'}
  end
end
