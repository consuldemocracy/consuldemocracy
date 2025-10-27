module RemoteTranslations
  module Llm
    class Config
      class << self
        def context
          @context = RubyLLM.context do |config|
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
