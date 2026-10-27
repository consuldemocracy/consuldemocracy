# frozen_string_literal: true

RSpec.shared_context "sensemaker llm config" do
  let(:llm_config) do
    double(
      "LLM config",
      vertexai_project_id: "sensemaker-466109",
      vertexai_location: "global",
      openai_api_key: "openai-secret",
      openai_api_base: "https://openai-proxy.example.com/v1",
      openrouter_api_key: "openrouter-secret",
      openrouter_api_base: "https://openrouter.ai/api/v1",
      together_api_key: "together-secret",
      together_api_base: "https://api.together.xyz/v1",
      mistral_api_key: "mistral-secret",
      mistral_api_base: "https://api.mistral.ai/v1",
      ollama_api_base: "http://localhost:11434"
    )
  end
  let(:llm_context) { double("LLM context", config: llm_config) }
end
