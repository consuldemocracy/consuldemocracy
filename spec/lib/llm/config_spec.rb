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

      expect(Llm::Config.providers.values.map { |provider| provider[:enabled] }).to all be_falsy
    end
  end

  describe ".speech_to_text_configured?" do
    before do
      Setting["llm.use_llm_speech_to_text"] = true
      Setting["llm.speech_to_text_provider"] = "OpenAI"
      Setting["llm.speech_to_text_model"] = "whisper-1"
      stub_secrets(llm: { openai_api_key: "1234" })
    end

    it "returns true when the feature is enabled and the model is available" do
      expect(Llm::Config.speech_to_text_configured?).to be true
    end

    it "does not require the content LLM provider or model" do
      Setting["llm.provider"] = nil
      Setting["llm.model"] = nil

      expect(Llm::Config.speech_to_text_configured?).to be true
    end

    it "returns false when the feature is disabled" do
      Setting["llm.use_llm_speech_to_text"] = nil

      expect(Llm::Config.speech_to_text_configured?).to be false
    end
  end

  describe ".speech_to_text_models_for" do
    it "returns models for the given provider" do
      expect(Llm::Config.speech_to_text_models_for("OpenAI")).to eq(
        %w[whisper-1 gpt-4o-transcribe gpt-4o-mini-transcribe gpt-4o-transcribe-diarize]
      )
      expect(Llm::Config.speech_to_text_models_for(:gemini)).to eq(%w[gemini-2.5-flash gemini-2.5-pro])
    end

    it "returns an empty array for unknown providers" do
      expect(Llm::Config.speech_to_text_models_for("Anthropic")).to eq([])
    end
  end

  describe ".speech_to_text_model_available?" do
    before { Setting["llm.speech_to_text_provider"] = "OpenAI" }

    it "returns true when the model provider is configured" do
      stub_secrets(llm: { openai_api_key: "1234" })

      expect(Llm::Config.speech_to_text_model_available?("whisper-1")).to be true
    end

    it "returns false when the model provider is not configured" do
      stub_secrets(llm: { gemini_api_key: "1234" })

      expect(Llm::Config.speech_to_text_model_available?("whisper-1")).to be false
    end

    it "returns false when the speech-to-text provider setting is missing" do
      Setting["llm.speech_to_text_provider"] = nil
      stub_secrets(llm: { openai_api_key: "1234" })

      expect(Llm::Config.speech_to_text_model_available?("whisper-1")).to be false
    end

    it "returns false for models not in the speech-to-text list" do
      stub_secrets(llm: { openai_api_key: "1234" })

      expect(Llm::Config.speech_to_text_model_available?("gpt-4o")).to be false
    end
  end

  describe ".transcribe" do
    let(:context) { double("RubyLLM::Context") }

    before do
      allow(Llm::Config).to receive_messages(
        context: context,
        speech_to_text_configured?: true
      )
      Setting["llm.speech_to_text_provider"] = "OpenAI"
    end

    it "delegates transcription to RubyLLM with context and provider" do
      audio = StringIO.new("audio.wav")

      expect(RubyLLM).to receive(:transcribe).with(
        audio,
        model: "whisper-1",
        language: "en",
        provider: :openai,
        context: context
      )

      Llm::Config.transcribe(audio, model: "whisper-1", language: "en")
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
