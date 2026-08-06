module Llm
  class Config
    SPEECH_TO_TEXT_MODELS = {
      "OpenAI" => %w[whisper-1 gpt-4o-transcribe gpt-4o-mini-transcribe gpt-4o-transcribe-diarize],
      "Gemini" => %w[gemini-2.5-flash gemini-2.5-pro]
    }.freeze

    class << self
      def context
        RubyLLM.context do |config|
          ENV["GOOGLE_APPLICATION_CREDENTIALS"] ||= Rails.application.secrets.google_application_credentials

          llm_secrets.compact_blank.each do |key, value|
            config.send("#{key}=", value)
          end
        end
      end

      def providers
        RubyLLM::Providers.constants.to_h do |provider|
          [provider, { enabled: RubyLLM::Providers.const_get(provider).configured?(context.config) }]
        end
      end

      def prompts
        YAML.load_file("config/llm_prompts.yml", aliases: true)
      end

      def chat(provider: llm_provider, model: llm_model)
        context.chat(provider: provider, model: model)
      end

      def transcribe(audio_file, model:, language: nil)
        unless speech_to_text_configured?
          raise RubyLLM::ConfigurationError, I18n.t("speech_to_text.errors.llm_not_configured")
        end

        audio_file.rewind if audio_file.respond_to?(:rewind)

        RubyLLM.transcribe(
          audio_file,
          model: model,
          language: language,
          provider: speech_to_text_provider,
          context: context
        )
      end

      def configured?
        llm_provider.present? && llm_model.present?
      end

      def speech_to_text_configured?
        Setting["llm.use_llm_speech_to_text"].present? && speech_to_text_model_available?
      end

      def speech_to_text_model_available?(model = Setting["llm.speech_to_text_model"])
        provider = speech_to_text_provider
        return false if model.blank? || provider.blank?

        configured_providers = providers
        provider_key = configured_providers.keys.find { |key| key.to_s.casecmp(provider.to_s).zero? }
        return false unless provider_key && configured_providers[provider_key][:enabled]

        speech_to_text_models_for(provider).include?(model)
      end

      def speech_to_text_models_for(provider)
        SPEECH_TO_TEXT_MODELS.find { |name, _| name.casecmp?(provider.to_s) }&.last || []
      end

      private

        def llm_provider
          Setting["llm.provider"]&.downcase&.to_sym
        end

        def llm_model
          Setting["llm.model"]
        end

        def speech_to_text_provider
          Setting["llm.speech_to_text_provider"]&.downcase&.to_sym
        end

        def llm_secrets
          Tenant.current_secrets.llm || {}
        end
    end
  end
end
