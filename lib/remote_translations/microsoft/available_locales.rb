require "net/https"
require "uri"
require "cgi"
require "json"

module RemoteTranslations::Microsoft::AvailableLocales

  def load_remote_locales
    remote_available_locales.map { |locale| locale.first }
  end

  def parse_locale(locale)
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

  private

    def remote_available_locales
      host = "https://api.cognitive.microsofttranslator.com"
      path = "/languages?api-version=3.0"

      uri = URI (host + path)

      request = Net::HTTP::Get.new(uri)
      request["Ocp-Apim-Subscription-Key"] = Rails.application.secrets.microsoft_api_key

      response = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == "https") do |http|
        http.request (request)
      end

      result = response.body.force_encoding("utf-8")

      JSON.parse(result)["translation"]
    end

end
