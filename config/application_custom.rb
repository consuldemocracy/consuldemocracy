module Consul
  class Application < Rails::Application
    config.i18n.available_locales = [:va, :es]
    config.i18n.fallbacks = {'va' => 'es'}
  end
end
