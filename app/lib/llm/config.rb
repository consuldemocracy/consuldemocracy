module Llm
  class Config
    class << self
      def context
        RubyLLM.context do |config|
          ENV["GOOGLE_APPLICATION_CREDENTIALS"] ||= Rails.application.secrets.google_application_credentials

          llm_secrets.each do |key, value|
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
