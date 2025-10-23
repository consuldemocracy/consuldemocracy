require "rails_helper"

describe RemoteTranslations::Caller do
  describe ".llm?" do
    it "is true when all LLM settings are present" do
      Setting["llm.provider"] = "OpenAI"
      Setting["llm.model"] = "gpt-4o-mini"
      Setting["llm.use_llm_for_translations"] = true

      expect(RemoteTranslations::Caller.llm?).to be true
    end

    it "is false when any LLM setting is missing" do
      Setting["llm.provider"] = "OpenAI"
      Setting["llm.model"] = nil
      Setting["llm.use_llm_for_translations"] = true

      expect(RemoteTranslations::Caller.llm?).to be false
    end
  end

  describe ".translation_provider" do
    it "returns Llm when llm? is true" do
      allow(RemoteTranslations::Caller).to receive(:llm?).and_return(true)

      expect(RemoteTranslations::Caller.translation_provider).to eq(RemoteTranslations::Llm)
    end

    it "returns Microsoft when llm? is false" do
      allow(RemoteTranslations::Caller).to receive(:llm?).and_return(false)

      expect(RemoteTranslations::Caller.translation_provider).to eq(RemoteTranslations::Microsoft)
    end
  end

  describe ".configured?" do
    it "is true if llm? is true regardless of microsoft key" do
      allow(RemoteTranslations::Caller).to receive(:llm?).and_return(true)
      allow(Tenant).to receive_message_chain(:current_secrets, :microsoft_api_key).and_return(nil)

      expect(RemoteTranslations::Caller.configured?).to be true
    end

    it "falls back to microsoft settings when llm? is false" do
      allow(RemoteTranslations::Caller).to receive(:llm?).and_return(false)
      Setting["feature.remote_translations"] = true
      allow(Tenant).to receive_message_chain(:current_secrets, :microsoft_api_key).and_return("key")

      expect(RemoteTranslations::Caller.configured?).to be true
    end
  end
end
