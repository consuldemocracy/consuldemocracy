require "net/https"
require "uri"
require "cgi"
require "json"

class RemoteTranslations::Microsoft::AvailableLocales
  def self.available_locales
    daily_cache("locales") do
      remote_available_locales.map(&:first)
    end
  end

  def self.parse_locale(locale)
    case locale
    when :"pt-BR"
      :pt
    when :"zh-CN"
      :"zh-Hans"
    when :"zh-TW"
      :"zh-Hant"
    else
      locale
    end
  end

  def self.include_locale?(locale)
    available_locales.include?(parse_locale(locale).to_s)
  end

  private

    def self.remote_available_locales
      host = "https://api.cognitive.microsofttranslator.com"
      path = "/languages?api-version=3.0"

      uri = URI(host + path)

      request = Net::HTTP::Get.new(uri)
      request["Ocp-Apim-Subscription-Key"] = Rails.application.secrets.microsoft_api_key

      response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https") do |http|
        http.request(request)
      end

      result = response.body.force_encoding("utf-8")

      JSON.parse(result)["translation"]
    end

    def self.daily_cache(key, &block)
      Rails.cache.fetch("remote_available_locales/#{Time.current.strftime("%Y-%m-%d")}/#{key}", &block)
    end
end
