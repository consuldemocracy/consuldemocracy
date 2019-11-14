require "rails_helper"

describe SearchDictionarySelector do
  context "from I18n default locale" do
    before do
      @original_i18n_default = I18n.default_locale
    end

    after do
      I18n.default_locale = @original_i18n_default
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
