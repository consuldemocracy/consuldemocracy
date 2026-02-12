module Llm
  class Config
    class << self
      def context
        @context = RubyLLM.context do |config|
          llm_secrets = Tenant.current_secrets.llm

          credentials_path = llm_secrets&.fetch(:google_application_credentials, nil)
          if credentials_path.present?
            ENV["GOOGLE_APPLICATION_CREDENTIALS"] = credentials_path
          end

          llm_secrets&.each do |key, value|
            next if key.to_s == "google_application_credentials"

            config.send("#{key}=", value)
          end
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
