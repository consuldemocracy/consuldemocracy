require "rails_helper"

describe Llm::Config do
  describe ".context" do
    before { stub_secrets(llm: { openai_api_key: "1234" }) }

    it "creates a context with tenant secrets without errors" do
      config = instance_double(RubyLLM::Configuration)
      expect(config).to receive(:openai_api_key=).with("1234")
      context = double("RubyLLM::Context", config: config)
      expect(RubyLLM).to receive(:context).and_yield(config).and_return(context)

      expect { Llm::Config.context }.not_to raise_error
    end

    it "sets GOOGLE_APPLICATION_CREDENTIALS when google_application_credentials is present" do
      stub_secrets(
        llm: { openai_api_key: "1234" },
        google_application_credentials: "/tmp/dummy.json"
      )

      config = instance_double(RubyLLM::Configuration)
      allow(config).to receive(:openai_api_key=)
      context = double("RubyLLM::Context", config: config)
      expect(RubyLLM).to receive(:context).and_yield(config).and_return(context)

      original = ENV["GOOGLE_APPLICATION_CREDENTIALS"]
      begin
        Llm::Config.context
        expect(ENV["GOOGLE_APPLICATION_CREDENTIALS"]).to eq("/tmp/dummy.json")
      ensure
        ENV["GOOGLE_APPLICATION_CREDENTIALS"] = original
      end
    end
  end

  describe ".providers" do
    before do
      dummy_provider = Class.new do
        def self.configured?(_config)
          true
        end
      end
      stub_const("RubyLLM::Providers::OpenAI", dummy_provider)
    end

    it "maps provider enabled status using RubyLLM providers" do
      context = double("RubyLLM::Context", config: instance_double(RubyLLM::Configuration))
      allow(Llm::Config).to receive(:context).and_return(context)
      allow(RubyLLM::Providers).to receive(:constants).and_return([:OpenAI])

      providers = Llm::Config.providers

      expect(providers).to eq({ OpenAI: { enabled: true }})
    end
  end

  describe "evaluates provider configuration across different tenants" do
    before do
      stub_secrets(
        llm: {
          openai_api_key: "1234"
        },
        tenants: {
          new_tenant_name: {
            llm: {
              deepseek_api_key: "1234",
              openrouter_api_key: "1234"
            }
          }
        }
      )
    end

    it "enables OpenAI for the default tenant" do
      allow(Tenant).to receive(:current_schema).and_return("public")

      providers = Llm::Config.providers

      expect(providers[:DeepSeek]).to include(enabled: false)
      expect(providers[:OpenRouter]).to include(enabled: false)
      expect(providers[:OpenAI]).to include(enabled: true)
    end

    it "enables DeepSeek and OpenRouter for the new_tenant_name tenant" do
      allow(Tenant).to receive(:current_schema).and_return("new_tenant_name")

      providers = Llm::Config.providers

      expect(providers[:DeepSeek]).to include(enabled: true)
      expect(providers[:OpenRouter]).to include(enabled: true)
      expect(providers[:OpenAI]).to include(enabled: false)
    end
  end
end
