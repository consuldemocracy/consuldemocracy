module Llm
  class Config
    class << self
      def context
        @context = RubyLLM.context do |config|
          ENV["GOOGLE_APPLICATION_CREDENTIALS"] ||= Rails.application.secrets.google_application_credentials

          Tenant.current_secrets.llm&.each do |key, value|
            config.send("#{key}=", value)
          end
          config.max_retries = 3
          config.retry_interval = 12.0 # Start with 12 seconds (for 5 RPM)
          config.retry_backoff_factor = 2
          config.retry_interval_randomness = 0.5
        end
      end

      def providers
        RubyLLM::Providers.constants.each_with_object({}) do |provider, hash|
          hash[provider] = { enabled: RubyLLM::Providers.const_get(provider).configured?(context.config) }
        end
      end
    end
  end
end
