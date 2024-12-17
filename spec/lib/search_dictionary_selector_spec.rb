require "rails_helper"

describe SearchDictionarySelector do
  context "from I18n default locale" do
    before { allow(subject).to receive(:call).and_call_original }

    it "returns correct dictionary for simple locale" do
      Setting["locales.default"] = "es"

      expect(subject.call).to eq("spanish")
    end

    it "returns correct dictionary for compound locale" do
      Setting["locales.default"] = "pt-BR"

      expect(subject.call).to eq("portuguese")
    end

    it "returns simple for unsupported locale" do
      allow(I18n).to receive(:available_locales).and_return(%i[en pl])
      Setting["locales.default"] = "pl"

      expect(subject.call).to eq("simple")
    end
  end
end
