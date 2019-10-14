# encoding: utf-8

# Tolk config file. Generated on January 14, 2016 12:09
# See github.com/tolk/tolk for more informations

Tolk.config do |config|

  # If you need to add a mapping do it like this :
  # May we suggest you use http://en.wikipedia.org/wiki/List_of_ISO_639-1_codes
  # config.mapping['en-AU']   = 'English (Australia)'
  # config.mapping['es-MX']   = 'Spanish (Mexico)'
  # config.mapping['fr-ES']   = 'Frañol !'
  # config.mapping['is']      = 'Icelandic'
  # config.mapping['vi']      = 'Vietnamese'

  # Master source of strings to be translated
  config.primary_locale_name = 'en'
end

Tolk::ApplicationController.authenticator = proc {
  authenticate_or_request_with_http_basic do |username, password|
    username == Rails.application.secrets.translate_username &&
      password == Rails.application.secrets.translate_password
  end
}
