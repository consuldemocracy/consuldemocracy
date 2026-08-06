require "rails_helper"

describe Llm::Config do
  describe ".context" do
    let(:config) { double }
    let(:context_double) { double(config: config) }

    before do
      stub_secrets(llm: { openai_api_key: "1234" })
      allow(config).to receive(:openai_api_key=)
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
    it "maps provider enabled status using configured providers" do
      stub_secrets(llm: { openai_api_key: "1234" })

      providers = Llm::Config.providers

      expect(providers[:OpenAI]).to eq({ enabled: true })
      expect(providers[:DeepSeek]).to eq({ enabled: false })
    end

    it "discards providers with a blank configuration" do
      stub_secrets(llm: { openai_api_key: "" })

      expect(Llm::Config.providers[:OpenAI]).to eq({ enabled: false })
    end

    it "does not enable any providers when the LLM configuration is nil" do
      stub_secrets({})

      expect(Llm::Config.providers.values).to all eq({ enabled: false })
    end
  end

  describe ".sensemaker_adapter_for" do
    it "maps supported providers" do
      expect(Llm::Config.sensemaker_adapter_for("VertexAI")).to eq("vertex")
      expect(Llm::Config.sensemaker_adapter_for("OpenAI")).to eq("openai-compatible")
      expect(Llm::Config.sensemaker_adapter_for("OpenRouter")).to eq("openai-compatible")
      expect(Llm::Config.sensemaker_adapter_for("Mistral")).to eq("openai-compatible")
      expect(Llm::Config.sensemaker_adapter_for("Ollama")).to eq("ollama")
    end

    it "returns nil for unsupported providers" do
      expect(Llm::Config.sensemaker_adapter_for("Anthropic")).to be_nil
      expect(Llm::Config.sensemaker_adapter_for("Gemini")).to be_nil
    end
  end

  describe ".sensemaker_supported_providers" do
    it "includes only providers with a Sensemaker adapter" do
      stub_secrets(llm: { openai_api_key: "1234" })

      supported = Llm::Config.sensemaker_supported_providers

      expect(supported.keys).to include(:OpenAI)
      expect(supported.keys).not_to include(:Anthropic)
    end
  end

  describe ".sensemaker_model_available?" do
    before do
      Setting["llm.sensemaker_provider"] = "OpenAI"
      Setting["llm.sensemaker_model"] = "gpt-4o"
      stub_secrets(llm: { openai_api_key: "1234" })
    end

    it "returns true when the Sensemaker provider is credentialed and model is set" do
      expect(Llm::Config.sensemaker_model_available?).to be true
    end

    it "does not require the content LLM provider or model" do
      Setting["llm.provider"] = nil
      Setting["llm.model"] = nil

      expect(Llm::Config.sensemaker_model_available?).to be true
    end

    it "returns false when the model is missing" do
      Setting["llm.sensemaker_model"] = nil

      expect(Llm::Config.sensemaker_model_available?).to be false
    end

    it "returns false when the provider setting is missing" do
      Setting["llm.sensemaker_provider"] = nil

      expect(Llm::Config.sensemaker_model_available?).to be false
    end

    it "returns false when the provider credentials are not configured" do
      stub_secrets(llm: { gemini_api_key: "1234" })

      expect(Llm::Config.sensemaker_model_available?).to be false
    end

    it "returns false for unsupported providers" do
      Setting["llm.sensemaker_provider"] = "Anthropic"
      stub_secrets(llm: { anthropic_api_key: "1234" })

      expect(Llm::Config.sensemaker_model_available?).to be false
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
