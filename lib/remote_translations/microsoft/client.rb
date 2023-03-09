class RemoteTranslations::Microsoft::Client
  include SentencesParser
  CHARACTERS_LIMIT_PER_REQUEST = 5000
  PREVENTING_TRANSLATION_KEY = "notranslate".freeze

  def call(fields_values, locale)
    texts = prepare_texts(fields_values)
    valid_locale = RemoteTranslations::Microsoft::AvailableLocales.app_locale_to_remote_locale(locale)
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

    def client
      @client ||= BingTranslator.new(Tenant.current_secrets.microsoft_api_key)
    end

    def request_translation(texts, locale)
      response = []
      split_response = false

      if characters_count(texts) <= CHARACTERS_LIMIT_PER_REQUEST
        response = client.translate_array(texts, to: locale)
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
        client.translate_array([fragment], to: locale)
      end.flatten
    end

    def parse_response(response, split_response)
      response.map do |translation|
        if split_response
          build_translation(translation)
        else
          get_field_value(translation)
        end
      end
    end

    def build_translation(translations)
      translations.map { |translation| get_field_value(translation) }.join
    end

    def get_field_value(translation)
      notranslate?(translation) ? nil : translation
    end

    def prepare_texts(texts)
      texts.map { |text| text || PREVENTING_TRANSLATION_KEY }
      #https://docs.microsoft.com/es-es/azure/cognitive-services/translator/prevent-translation
    end

    def notranslate?(text)
      text.downcase == PREVENTING_TRANSLATION_KEY
    end
end
