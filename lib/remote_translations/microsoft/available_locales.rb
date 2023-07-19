require "net/https"
require "uri"
require "cgi"
require "json"

class RemoteTranslations::Microsoft::AvailableLocales
  def self.locales
    daily_cache("locales") do
      remote_available_locales.map { |locale| remote_locale_to_app_locale(locale) }
    end
  end

  def self.app_locale_to_remote_locale(locale)
    app_locale_to_remote_locale_map[locale] || locale
  end

  def self.include_locale?(locale)
    locales.include?(locale.to_s)
  end

  private

    def self.remote_locale_to_app_locale(locale)
      app_locale_to_remote_locale_map.invert[locale] || locale
    end

    def self.app_locale_to_remote_locale_map
      {
        "pt-BR" => "pt",
        "zh-CN" => "zh-Hans",
        "zh-TW" => "zh-Hant"
      }
    end

    def self.remote_available_locales
      host = "https://api.cognitive.microsofttranslator.com"
      path = "/languages?api-version=3.0"

      uri = URI(host + path)

      request = Net::HTTP::Get.new(uri)
      request["Ocp-Apim-Subscription-Key"] = Tenant.current_secrets.microsoft_api_key

      response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https") do |http|
        http.request(request)
      end

      result = response.body.force_encoding("utf-8")

      JSON.parse(result)["translation"].map(&:first)
    end

    def self.daily_cache(key, &block)
      Rails.cache.fetch("remote_available_locales/#{Time.current.strftime("%Y-%m-%d")}/#{key}", &block)
    end
end
