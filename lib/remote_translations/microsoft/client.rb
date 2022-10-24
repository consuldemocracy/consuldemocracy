require "translator-text"
include RemoteTranslations::Microsoft::SentencesParser

class RemoteTranslations::Microsoft::Client
  CHARACTERS_LIMIT_PER_REQUEST = 5000
  PREVENTING_TRANSLATION_KEY = "notranslate".freeze

  def initialize
    api_key = Rails.application.secrets.microsoft_api_key
    @client = TranslatorText::Client.new(api_key)
  end

  def call(fields_values, locale)
    texts = prepare_texts(fields_values)
    valid_locale = RemoteTranslations::Microsoft::AvailableLocales.parse_locale(locale)
    request_translation(texts, valid_locale)
  end

  def fragments_for(text)
    return [text] if text.size <= CHARACTERS_LIMIT_PER_REQUEST

    split_position = detect_split_position(text)
    start_text = text[0..split_position]
    end_text = text[split_position + 1..text.size]

    fragments_for(start_text) + [end_text]
  end

  private

    def request_translation(texts, locale)
      response = []
      split_response = false

      if characters_count(texts) <= CHARACTERS_LIMIT_PER_REQUEST
        response = @client.translate(texts, to: locale)
      else
        texts.each do |text|
          response << translate_text(text, locale)
        end
        split_response = true
      end

      parse_response(response, split_response)
    end

    def translate_text(text, locale)
      fragments_for(text).map do |fragment|
        @client.translate([fragment], to: locale)
      end.flatten
    end

    def parse_response(response, split_response)
      response.map do |object|
        if split_response
          build_translation(object)
        else
          get_field_value(object)
        end
      end
    end

    def build_translation(objects)
      objects.map { |object| get_field_value(object) }.join
    end

    def get_field_value(object)
      text = object.translations[0].text
      notranslate?(text) ? nil : text
    end

    def prepare_texts(texts)
      texts.map { |text| text || PREVENTING_TRANSLATION_KEY }
      #https://docs.microsoft.com/es-es/azure/cognitive-services/translator/prevent-translation
    end

    def notranslate?(text)
      text.downcase == PREVENTING_TRANSLATION_KEY
    end
end
