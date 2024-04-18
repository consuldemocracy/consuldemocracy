require "rails_helper"

describe LocalesHelper do
  context "Language names" do
    around do |example|
      I18n.with(enforce_available_locales: false) { example.run }
    end

    after do
      I18n.backend.reload!
      I18n.backend.send(:init_translations)
    end

    it "returns the language name in i18n.language.name translation" do
      keys = { language: { name: "World Language" }}

      I18n.backend.store_translations(:wl, { i18n: keys })

      expect(name_for_locale(:wl)).to eq("World Language")
    end

    it "retuns the locale key if i18n.language.name translation is not found" do
      expect(name_for_locale(:wl)).to eq("wl")
    end
  end
end
