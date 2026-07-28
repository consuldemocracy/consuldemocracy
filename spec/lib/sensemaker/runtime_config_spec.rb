require "rails_helper"

describe Sensemaker::RuntimeConfig do
  let(:setting) { class_double(Setting) }
  let(:llm_config) do
    double(
      "LLM config",
      vertexai_project_id: "sensemaker-466109",
      vertexai_location: "global",
      openai_api_key: "openai-secret",
      openai_api_base: "https://openai-proxy.example.com/v1",
      openrouter_api_key: "openrouter-secret",
      openrouter_api_base: "https://openrouter.ai/api/v1",
      mistral_api_key: "mistral-secret",
      mistral_api_base: "https://api.mistral.ai/v1",
      ollama_api_base: "http://localhost:11434"
    )
  end
  let(:llm_context) { double("LLM context", config: llm_config) }
  let(:runtime_config) { Sensemaker::RuntimeConfig.new(setting: setting, llm_context: llm_context) }

  before do
    allow(setting).to receive(:[]).and_return(nil)
  end

  describe "#provider and #model" do
    it "normalizes provider and returns selected model" do
      allow(setting).to receive(:[]).with("llm.provider").and_return(" OpenAI ")
      allow(setting).to receive(:[]).with("llm.model").and_return("gpt-4.1-mini")

      expect(runtime_config.provider).to eq("openai")
      expect(runtime_config.model).to eq("gpt-4.1-mini")
    end
  end

  describe "#adapter" do
    it "maps vertex provider to vertex adapter" do
      allow(setting).to receive(:[]).with("llm.provider").and_return("VertexAI")
      expect(runtime_config.adapter).to eq("vertex")
    end

    it "maps openai provider to openai-compatible adapter" do
      allow(setting).to receive(:[]).with("llm.provider").and_return("OpenAI")
      expect(runtime_config.adapter).to eq("openai-compatible")
    end

    it "maps ollama provider to ollama adapter" do
      allow(setting).to receive(:[]).with("llm.provider").and_return("ollama")
      expect(runtime_config.adapter).to eq("ollama")
    end

    it "returns nil for unsupported provider" do
      allow(setting).to receive(:[]).with("llm.provider").and_return("unsupported")
      expect(runtime_config.adapter).to be(nil)
      expect(runtime_config.supported?).to be(false)
    end
  end

  describe "#compat_provider, #api_key and #base_url" do
    it "resolves openai-compatible provider settings" do
      allow(setting).to receive(:[]).with("llm.provider").and_return("OpenAI")

      expect(runtime_config.compat_provider).to eq("openai")
      expect(runtime_config.api_key).to eq("openai-secret")
      expect(runtime_config.base_url).to eq("https://openai-proxy.example.com/v1")
    end

    it "resolves openrouter provider settings" do
      allow(setting).to receive(:[]).with("llm.provider").and_return("OpenRouter")

      expect(runtime_config.adapter).to eq("openai-compatible")
      expect(runtime_config.compat_provider).to eq("openrouter")
      expect(runtime_config.api_key).to eq("openrouter-secret")
      expect(runtime_config.base_url).to eq("https://openrouter.ai/api/v1")
    end

    it "resolves ollama base url" do
      allow(setting).to receive(:[]).with("llm.provider").and_return("ollama")

      expect(runtime_config.compat_provider).to be(nil)
      expect(runtime_config.api_key).to be(nil)
      expect(runtime_config.base_url).to eq("http://localhost:11434")
    end

    it "returns nil api_key/base_url when config methods are unavailable" do
      limited_config = double("LLM config", vertexai_project_id: "proj", vertexai_location: nil)
      limited_context = double("LLM context", config: limited_config)
      cfg = Sensemaker::RuntimeConfig.new(setting: setting, llm_context: limited_context)
      allow(setting).to receive(:[]).with("llm.provider").and_return("OpenAI")

      expect(cfg.api_key).to be(nil)
      expect(cfg.base_url).to be(nil)
    end
  end

  describe "#vertex_project_id and #vertex_location" do
    it "returns vertex project and location" do
      expect(runtime_config.vertex_project_id).to eq("sensemaker-466109")
      expect(runtime_config.vertex_location).to eq("global")
    end

    it "defaults vertex location to global when blank" do
      allow(llm_config).to receive(:vertexai_location).and_return(nil)
      expect(runtime_config.vertex_location).to eq("global")
    end
  end
end
