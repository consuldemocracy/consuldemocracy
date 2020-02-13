module Consul
  class Application < Rails::Application
    config.i18n.default_locale = 'sr'
    # available_locales = %w(ar de en es fa fr gl he it nl pl pt-BR sq sv val zh-CN zh-TW sl sl-SI)
    available_locales = %w(sr en)
    config.i18n.available_locales = available_locales
    config.i18n.fallbacks = {
      'sr' => 'en'
      # 'fr' => 'es',
      # 'gl' => 'es',
      # 'it' => 'es',
      # 'pt-BR' => 'es',
      # 'sl-SI' => 'sl',
    }
  end
end
