require "rails_helper"

describe Llm::Config do
  describe ".context" do
    let(:config) { instance_double(RubyLLM::Configuration) }
    let(:context_double) { double("RubyLLM::Context", config: config) }

    before do
      stub_secrets(llm: { openai_api_key: "1234" })
      allow(config).to receive(:openai_api_key=)
      allow(config).to receive(:ollama_api_base).and_return(nil)
      expect(RubyLLM).to receive(:context).and_yield(config).and_return(context_double)
    end

    it "creates a context with tenant secrets without errors" do
      expect(config).to receive(:openai_api_key=).with("1234")

      expect { Llm::Config.context }.not_to raise_error
    end

    context "google_application_credentials is present" do
      before do
        stub_secrets(
          llm: { openai_api_key: "1234" },
          google_application_credentials: "/tmp/dummy.json"
        )
        allow(config).to receive(:ollama_api_base).and_return(nil)
      end

      let!(:original_google_application_credentials) { ENV["GOOGLE_APPLICATION_CREDENTIALS"] }
      after { ENV["GOOGLE_APPLICATION_CREDENTIALS"] = original_google_application_credentials }

      it "sets GOOGLE_APPLICATION_CREDENTIALS" do
        Llm::Config.context

        expect(ENV["GOOGLE_APPLICATION_CREDENTIALS"]).to eq("/tmp/dummy.json")
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
