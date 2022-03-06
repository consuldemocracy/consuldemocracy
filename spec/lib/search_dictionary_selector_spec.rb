require "rails_helper"

describe SearchDictionarySelector do
  context "from I18n default locale" do
    before { allow(subject).to receive(:call).and_call_original }
    around do |example|
      original_i18n_default = I18n.default_locale
      begin
        example.run
      ensure
        I18n.default_locale = original_i18n_default
      end
    end

    it "returns correct dictionary for simple locale" do
      I18n.default_locale = :es
      expect(subject.call).to eq("spanish")
    end

    it "returns correct dictionary for compound locale" do
      I18n.default_locale = :"pt-BR"
      expect(subject.call).to eq("portuguese")
    end

    it "returns simple for unsupported locale" do
      expect(I18n).to receive(:default_locale).and_return(:pl) # avoiding I18n::InvalidLocale
      expect(subject.call).to eq("simple")
    end
  end
end
