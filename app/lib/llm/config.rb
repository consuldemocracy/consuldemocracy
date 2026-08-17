module Llm
  class Config
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

        RubyLLM.models.find(model, provider).supports?(:transcription)
      rescue RubyLLM::ModelNotFoundError
        false
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
