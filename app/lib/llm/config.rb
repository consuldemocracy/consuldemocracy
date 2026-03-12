module Llm
  class Config
    class << self
      def context
        @context = RubyLLM.context do |config|
          ENV["GOOGLE_APPLICATION_CREDENTIALS"] ||= Rails.application.secrets.google_application_credentials

          Tenant.current_secrets.llm&.each do |key, value|
            config.send("#{key}=", value)
          end
        end

        # Sync local models into the global registry
        sync_registry_with_ollama(@context.config)

        @context
      end

      def providers
        RubyLLM::Providers.constants.each_with_object({}) do |provider_const, hash|
          provider_class = RubyLLM::Providers.const_get(provider_const)
          next unless provider_class.respond_to?(:configured?)

          hash[provider_const] = {
            enabled: provider_class.configured?(context.config)
          }
        end
      end

      private

        # Fetches dynamic models from Ollama and injects them into RubyLLM::Models.
        def sync_registry_with_ollama(config)
          return if config.ollama_api_base.blank?

          begin
            provider = RubyLLM::Providers::Ollama.new(config)
            new_models = provider.list_models

            if new_models.any?
              # Merge with existing models (OpenAI/Anthropic/etc)
              existing_non_ollama = RubyLLM.models.all.reject { |m| m.provider == "ollama" }

              # Update the global singleton instance
              combined_registry = RubyLLM::Models.new(existing_non_ollama + new_models)
              RubyLLM::Models.instance_variable_set(:@instance, combined_registry)
            end
          rescue => e
            # Log failure but don't crash the app; cloud models will still work.
            Rails.logger.warn "[Llm::Config] Ollama sync failed: #{e.message} " \
                              "(URL: #{config.ollama_api_base})"
          end
        end
    end
  end
end
