require "rails_helper"

describe Sensemaker do
  describe ".enabled?" do
    before do
      Setting["llm.provider"] = "OpenAI"
      Setting["llm.model"] = "gpt-4o"
      Setting["llm.use_sensemaker"] = true
    end

    it "is true when LLM is configured and the toggle is on" do
      expect(Sensemaker.enabled?).to be true
    end

    it "is false when the toggle is off" do
      Setting["llm.use_sensemaker"] = false

      expect(Sensemaker.enabled?).to be false
    end

    it "is false when the provider is missing" do
      Setting["llm.provider"] = nil

      expect(Sensemaker.enabled?).to be false
    end

    it "is false when the model is missing" do
      Setting["llm.model"] = nil

      expect(Sensemaker.enabled?).to be false
    end
  end
end
