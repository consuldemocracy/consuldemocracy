require "rails_helper"

describe RemoteTranslations::Llm::Config do
  # Ensure memoized context from RemoteTranslations::Llm::Config doesn't leak doubles
  after do
    if RemoteTranslations::Llm::Config.instance_variable_defined?(:@context)
      RemoteTranslations::Llm::Config.remove_instance_variable(:@context)
    end
  end

  describe ".context" do
    it "creates a context with tenant secrets without errors" do
      secrets = { openai_access_token: "token" }
      allow(Tenant).to receive(:current_secrets).and_return(double(llm: secrets))

      config_double = double("RubyLLM::Configuration", openai_access_token: nil)
      allow(config_double).to receive(:openai_access_token=)
      context_double = double(config: config_double)
      allow(RubyLLM).to receive(:context).and_yield(config_double).and_return(context_double)

      expect { RemoteTranslations::Llm::Config.context }.not_to raise_error
    end
  end

  describe ".providers" do
    it "maps provider enabled status using RubyLLM providers" do
      config_double = double
      context = double(config: config_double)
      allow(RemoteTranslations::Llm::Config).to receive(:context).and_return(context)

      stub_provider = Class.new do
        def self.configured?(config)
          true
        end
      end

      stub_const("RubyLLM::Providers::OpenAI", stub_provider)
      allow(RubyLLM::Providers).to receive(:constants).and_return([:OpenAI])

      providers = RemoteTranslations::Llm::Config.providers
      expect(providers).to include(:OpenAI)
      expect(providers[:OpenAI]).to include(:enabled)
      expect(providers[:OpenAI][:enabled]).to be true
    end
  end
end
