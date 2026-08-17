module SpeechToText
  module Llm
    class Client
      def self.call(audio_file:, locale:)
        new(audio_file: audio_file, locale: locale).call
      end

      def initialize(audio_file:, locale:)
        @audio_file = audio_file
        @locale = locale
      end

      def call
        unless ::Llm::Config.speech_to_text_configured?
          return Response.new(nil, [I18n.t("speech_to_text.errors.llm_not_configured")])
        end

        with_named_audio do |audio|
          transcription = RubyLLM.transcribe(
            audio,
            model: Setting["llm.speech_to_text_model"],
            language: locale_language,
            provider: Setting["llm.speech_to_text_provider"].downcase.to_sym,
            context: ::Llm::Config.context
          )

          Response.new(transcription.text.to_s.strip)
        end
      rescue RubyLLM::ConfigurationError
        Response.new(nil, [I18n.t("speech_to_text.errors.llm_not_configured")])
      rescue StandardError => e
        Rails.logger.error("#{e.class}: #{e.message}")
        Response.new(nil, [I18n.t("speech_to_text.errors.transcription_failed")])
      end

      class Response
        attr_reader :text, :errors

        def initialize(text = nil, errors = [])
          @text = text
          @errors = errors
        end
      end

      private

        def with_named_audio
          Tempfile.create(["speech_to_text", audio_extension]) do |file|
            @audio_file.tempfile.rewind
            IO.copy_stream(@audio_file.tempfile, file)
            file.flush
            yield file
          end
        end

        def audio_extension
          return ".m4a" if @audio_file.content_type == "audio/mp4"

          File.extname(@audio_file.original_filename.to_s).presence || ".webm"
        end

        def locale_language
          @locale.to_s.split("-").first.presence
        end
    end
  end
end
