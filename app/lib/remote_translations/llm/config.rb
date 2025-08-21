module RemoteTranslations
  module Llm
    class Config
      class << self
        def context
          # set credentials in the secrets.yml file, referencing https://rubyllm.com/configuration/#provider-configuration
          @context ||= RubyLLM.context do |config|
            Tenant.current_secrets.llm&.each do |key, value|
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
end
