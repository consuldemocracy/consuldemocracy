require "rails_helper"

describe Sensemaker do
  describe ".enabled?" do
    before do
      stub_secrets(llm: { openai_api_key: "1234" })
      Setting["llm.sensemaker_provider"] = "OpenAI"
      Setting["llm.sensemaker_model"] = "gpt-4o"
      Setting["llm.use_sensemaker"] = true
    end

    it "is true when Sensemaker LLM is configured and the toggle is on" do
      expect(Sensemaker.enabled?).to be true
    end

    it "does not require the content LLM provider or model" do
      Setting["llm.provider"] = nil
      Setting["llm.model"] = nil

      expect(Sensemaker.enabled?).to be true
    end

    it "is false when the toggle is off" do
      Setting["llm.use_sensemaker"] = false

      expect(Sensemaker.enabled?).to be false
    end

    it "is false when the Sensemaker provider is missing" do
      Setting["llm.sensemaker_provider"] = nil

      expect(Sensemaker.enabled?).to be false
    end

    it "is false when the Sensemaker model is missing" do
      Setting["llm.sensemaker_model"] = nil

      expect(Sensemaker.enabled?).to be false
    end

    it "is false when the Sensemaker provider credentials are missing" do
      stub_secrets(llm: {})

      expect(Sensemaker.enabled?).to be false
    end
  end
end
