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

      def sensemaker_adapter_for(provider_name)
        case provider_name.to_s.downcase
        when /vertex/
          "vertex"
        when /ollama/
          "ollama"
        when /openai/, /openrouter/, /mistral/
          "openai-compatible"
        end
      end

      def sensemaker_supported_providers
        providers.select do |key, _value|
          sensemaker_adapter_for(key).present?
        end
      end

      def sensemaker_models_for(provider)
        return [] if provider.blank?

        RubyLLM.models.by_provider(provider.to_s.downcase.to_sym).map do |model|
          [model.name, model.id]
        end
      end

      def sensemaker_model_available?(model = Setting["llm.sensemaker_model"])
        provider = Setting["llm.sensemaker_provider"]
        return false if model.blank? || provider.blank?
        return false if sensemaker_adapter_for(provider).blank?

        configured_providers = providers
        provider_key = configured_providers.keys.find { |key| key.to_s.casecmp(provider.to_s).zero? }
        return false unless provider_key && configured_providers[provider_key][:enabled]

        true
      end

      private

        def llm_provider
          Setting["llm.provider"]&.downcase&.to_sym
        end

        def llm_model
          Setting["llm.model"]
        end

        def llm_secrets
          Tenant.current_secrets.llm || {}
        end
    end
  end
end
